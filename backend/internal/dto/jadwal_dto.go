package dto

import "time"

type CreateJadwalDTO struct {
	PasienID           int       `json:"pasien_id" binding:"required"`
	NamaObat           string    `json:"nama_obat" binding:"required"`
	JumlahDosis        int       `json:"jumlah_dosis" binding:"required"`
	Satuan             string    `json:"satuan" binding:"required"`
	KategoriObat       string    `json:"kategori_obat" binding:"required"`
	TakaranObat        string    `json:"takaran_obat" binding:"required"`
	FrekuensiPerHari   int       `json:"frekuensi_per_hari" binding:"required"`
	WaktuMinum         string    `json:"waktu_minum" binding:"required"`
	AturanKonsumsi     string    `json:"aturan_konsumsi" binding:"required"`
	Catatan            string    `json:"catatan"`
	TipeDurasi         string    `json:"tipe_durasi" binding:"required"`
	JumlahHari         int       `json:"jumlah_hari"`
	TanggalMulai       time.Time `json:"tanggal_mulai"`
	TanggalSelesai     time.Time `json:"tanggal_selesai"`
	WaktuReminderPagi  string    `json:"waktu_reminder_pagi"`
	WaktuReminderMalam string    `json:"waktu_reminder_malam"`
	Status             string    `json:"status"`
}

type UpdateJadwalDTO struct {
	NamaObat           string    `json:"nama_obat"`
	JumlahDosis        int       `json:"jumlah_dosis"`
	Satuan             string    `json:"satuan"`
	KategoriObat       string    `json:"kategori_obat"`
	TakaranObat        string    `json:"takaran_obat"`
	FrekuensiPerHari   int       `json:"frekuensi_per_hari"`
	WaktuMinum         string    `json:"waktu_minum"`
	AturanKonsumsi     string    `json:"aturan_konsumsi"`
	Catatan            string    `json:"catatan"`
	TipeDurasi         string    `json:"tipe_durasi"`
	JumlahHari         int       `json:"jumlah_hari"`
	TanggalMulai       time.Time `json:"tanggal_mulai"`
	TanggalSelesai     time.Time `json:"tanggal_selesai"`
	WaktuReminderPagi  string    `json:"waktu_reminder_pagi"`
	WaktuReminderMalam string    `json:"waktu_reminder_malam"`
	Status             string    `json:"status"`
}

type JadwalResponseDTO struct {
	ID                 int       `json:"id"`
	PasienID           int       `json:"pasien_id"`
	PasienNama         string    `json:"pasien_nama"`
	NamaObat           string    `json:"nama_obat"`
	JumlahDosis        int       `json:"jumlah_dosis"`
	Satuan             string    `json:"satuan"`
	KategoriObat       string    `json:"kategori_obat"`
	TakaranObat        string    `json:"takaran_obat"`
	FrekuensiPerHari   int       `json:"frekuensi_per_hari"`
	WaktuMinum         string    `json:"waktu_minum"`
	AturanKonsumsi     string    `json:"aturan_konsumsi"`
	Catatan            string    `json:"catatan"`
	TipeDurasi         string    `json:"tipe_durasi"`
	JumlahHari         int       `json:"jumlah_hari"`
	TanggalMulai       time.Time `json:"tanggal_mulai"`
	TanggalSelesai     time.Time `json:"tanggal_selesai"`
	WaktuReminderPagi  string    `json:"waktu_reminder_pagi"`
	WaktuReminderMalam string    `json:"waktu_reminder_malam"`
	Status             string    `json:"status"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}
