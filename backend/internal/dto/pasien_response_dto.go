package dto

type PasienResponseDTO struct {
	PasienID     int    `json:"pasien_id"`
	Nama         string `json:"nama"`
	Email        string `json:"email,omitempty"`
	NIK          string `json:"nik,omitempty"`
	TanggalLahir string `json:"tanggal_lahir,omitempty"`
	TempatLahir  string `json:"tempat_lahir,omitempty"`
	Alamat       string `json:"alamat,omitempty"`
	JenisKelamin string `json:"jenis_kelamin,omitempty"`
	NoTelepon    string `json:"no_telepon,omitempty"`
}
