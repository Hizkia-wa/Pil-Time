package domain

type Rutinitas struct {
	ID            int    `gorm:"primaryKey" json:"id"`
	PasienID      int    `json:"pasien_id"`
	NamaRutinitas string `json:"nama_rutinitas"`
	Deskripsi     string `json:"deskripsi"`
	WaktuReminder string `json:"waktu_reminder"`
	Status        string `json:"status"` // "active", "selesai", "terlambat"
}