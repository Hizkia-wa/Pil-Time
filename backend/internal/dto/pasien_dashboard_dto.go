package dto

import "time"

// PasienDashboardResponse adalah response untuk dashboard pasien
type PasienDashboardResponse struct {
	PasienID     int                `json:"pasien_id"`
	Nama         string             `json:"nama"`
	Email        string             `json:"email"`
	NoTelepon    string             `json:"no_telepon"`
	JenisKelamin string             `json:"jenis_kelamin"`
	TanggalLahir string             `json:"tanggal_lahir"`
	Alamat       string             `json:"alamat"`
	TodayJadwals []JadwalResponseDTO `json:"today_jadwals"`
	AllJadwals   []JadwalResponseDTO `json:"all_jadwals"`
}

// PasienJadwalResponse adalah response untuk mendapatkan jadwal pasien
type PasienJadwalResponse struct {
	PasienID     int                `json:"pasien_id"`
	Nama         string             `json:"nama"`
	Jadwals      []JadwalResponseDTO `json:"jadwals"`
}

// TodayMedicationResponse adalah response untuk jadwal obat hari ini
type TodayMedicationResponse struct {
	PasienID       int    `json:"pasien_id"`
	PasienNama     string `json:"pasien_nama"`
	TotalObat      int    `json:"total_obat"`
	MedicationList []struct {
		JadwalID       int       `json:"jadwal_id"`
		NamaObat       string    `json:"nama_obat"`
		WaktuMinum     string    `json:"waktu_minum"`
		Dosis          string    `json:"dosis"`
		JumlahDosis    int       `json:"jumlah_dosis"`
		Satuan         string    `json:"satuan"`
		AturanKonsumsi string    `json:"aturan_konsumsi"`
		TanggalSelesai time.Time `json:"tanggal_selesai"`
		Status         string    `json:"status"`
	} `json:"medication_list"`
}
