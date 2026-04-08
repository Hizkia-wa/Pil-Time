package dto

type RegisterPasienRequest struct {
	Nama         string `json:"nama"`
	Email        string `json:"email"`
	Password     string `json:"password"`
	Nik          string `json:"nik"`
	TanggalLahir string `json:"tanggal_lahir"`
}