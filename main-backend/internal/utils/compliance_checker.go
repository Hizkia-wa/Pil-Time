package utils

import (
	"errors"
	"fmt"
	"time"
)

// ================================================================
// COMPLIANCE CHECKER — PIL TIME
// Menentukan status kepatuhan pasien berdasarkan selisih waktu
// antara scheduled_time dan waktu konfirmasi minum obat.
//
// Kategori Status (sesuai domain/model TrackingJadwal):
//   - "Diminum"  : konfirmasi dalam 0 s/d 60 menit dari jadwal
//   - "Terlambat": konfirmasi dalam > 60 s/d 75 menit dari jadwal
//   - "Terlewat" : konfirmasi > 75 menit dari jadwal / tidak dikonfirmasi
// ================================================================

// ComplianceStatus adalah tipe string untuk status kepatuhan.
// Nilainya sesuai dengan enum di tabel tracking_jadwal.
type ComplianceStatus string

const (
	StatusDiminum   ComplianceStatus = "Diminum"
	StatusTerlambat ComplianceStatus = "Terlambat"
	StatusTerlewat  ComplianceStatus = "Terlewat"

	// Batas waktu (dalam menit)
	batasTepatWaktu int = 60 // 0 – 60 menit → Diminum
	batasTerlambat  int = 75 // 61 – 75 menit → Terlambat
	// > 75 menit → Terlewat
)

// ComplianceResult menyimpan hasil pengecekan beserta detail waktu.
type ComplianceResult struct {
	Status          ComplianceStatus `json:"status"`
	SelisihMenit    int              `json:"selisih_menit"`
	ScheduledTime   time.Time        `json:"scheduled_time"`
	ConfirmationTime time.Time       `json:"confirmation_time"`
	Keterangan      string           `json:"keterangan"`
}

// ----------------------------------------------------------------
// CheckCompliance — fungsi utama
//
// Parameters:
//   scheduledTime    : waktu jadwal dari database (time.Time, UTC/local)
//   confirmationTime : waktu pasien menekan "Konfirmasi Minum" (time.Time)
//
// Timezone-safe: fungsi ini bekerja berdasarkan selisih durasi,
// sehingga tidak sensitif terhadap timezone asalkan kedua parameter
// menggunakan zona waktu yang konsisten.
// ----------------------------------------------------------------
func CheckCompliance(scheduledTime, confirmationTime time.Time) ComplianceResult {
	// Normalisasi ke UTC untuk menghindari DST edge-case
	scheduledUTC := scheduledTime.UTC()
	confirmUTC := confirmationTime.UTC()

	diff := confirmUTC.Sub(scheduledUTC)
	minutes := int(diff.Minutes())

	var status ComplianceStatus
	var keterangan string

	switch {
	case minutes < 0:
		// Konfirmasi SEBELUM jadwal (misalnya minum lebih awal) → Diminum
		status = StatusDiminum
		keterangan = fmt.Sprintf("Dikonfirmasi %d menit sebelum jadwal (dianggap tepat waktu)", -minutes)

	case minutes <= batasTepatWaktu:
		status = StatusDiminum
		keterangan = fmt.Sprintf("Tepat waktu (%d menit dari jadwal)", minutes)

	case minutes <= batasTerlambat:
		status = StatusTerlambat
		keterangan = fmt.Sprintf("Terlambat %d menit dari jadwal (dalam toleransi 15 menit)", minutes)

	default:
		status = StatusTerlewat
		keterangan = fmt.Sprintf("Terlewat %d menit dari jadwal", minutes)
	}

	return ComplianceResult{
		Status:           status,
		SelisihMenit:     minutes,
		ScheduledTime:    scheduledTime,
		ConfirmationTime: confirmationTime,
		Keterangan:       keterangan,
	}
}

// ----------------------------------------------------------------
// CheckComplianceFromStrings — versi string-based untuk fleksibilitas
//
// Parameters:
//   tanggal          : "YYYY-MM-DD" (tanggal jadwal)
//   scheduledTimeStr : "HH:MM" (waktu_minum dari field jadwal)
//   confirmationTime : waktu konfirmasi (biasanya time.Now() di handler)
//   loc              : *time.Location timezone (misal time.LoadLocation("Asia/Jakarta"))
//
// Gunakan fungsi ini di handler HTTP ketika waktu jadwal disimpan
// sebagai string "HH:MM" di database (sesuai field waktu_minum Jadwal model).
// ----------------------------------------------------------------
func CheckComplianceFromStrings(
	tanggal string,
	scheduledTimeStr string,
	confirmationTime time.Time,
	loc *time.Location,
) (ComplianceResult, error) {
	if loc == nil {
		loc = time.UTC
	}

	// Parse tanggal + jam jadwal
	dateTimeStr := fmt.Sprintf("%s %s", tanggal, scheduledTimeStr)
	scheduled, err := time.ParseInLocation("2006-01-02 15:04", dateTimeStr, loc)
	if err != nil {
		return ComplianceResult{}, fmt.Errorf(
			"format waktu jadwal tidak valid (%q): %w", dateTimeStr, err,
		)
	}

	return CheckCompliance(scheduled, confirmationTime), nil
}

// ----------------------------------------------------------------
// MustCheckCompliance — panic-safe wrapper untuk unit test / seeder
// ----------------------------------------------------------------
func MustCheckCompliance(scheduledTime, confirmationTime time.Time) ComplianceStatus {
	result := CheckCompliance(scheduledTime, confirmationTime)
	return result.Status
}

// ----------------------------------------------------------------
// IsExpired — cek apakah jadwal sudah "Terlewat" berdasarkan waktu saat ini.
// Berguna untuk background job / cron yang menandai jadwal yang tidak dikonfirmasi.
//
// Parameters:
//   tanggal          : "YYYY-MM-DD"
//   scheduledTimeStr : "HH:MM"
//   now              : waktu referensi (biasanya time.Now())
//   loc              : timezone
// ----------------------------------------------------------------
func IsExpired(tanggal, scheduledTimeStr string, now time.Time, loc *time.Location) (bool, error) {
	if loc == nil {
		loc = time.UTC
	}

	dateTimeStr := fmt.Sprintf("%s %s", tanggal, scheduledTimeStr)
	scheduled, err := time.ParseInLocation("2006-01-02 15:04", dateTimeStr, loc)
	if err != nil {
		return false, fmt.Errorf("format waktu jadwal tidak valid (%q): %w", dateTimeStr, err)
	}

	diff := now.Sub(scheduled)
	minutes := int(diff.Minutes())
	return minutes > batasTerlambat, nil
}

// ----------------------------------------------------------------
// GetWIBLocation — helper untuk mendapatkan *time.Location WIB
// Panggil sekali dan cache hasilnya di level aplikasi.
// ----------------------------------------------------------------
func GetWIBLocation() (*time.Location, error) {
	loc, err := time.LoadLocation("Asia/Jakarta")
	if err != nil {
		return nil, errors.New("gagal memuat timezone Asia/Jakarta: " + err.Error())
	}
	return loc, nil
}
