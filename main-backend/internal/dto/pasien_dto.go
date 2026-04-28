package dto

type RegisterPasienRequest struct {
	Email        string `json:"email" binding:"required,email"`
	Password     string `json:"password" binding:"required,min=8"`
	NamaLengkap  string `json:"nama_lengkap" binding:"required,max=100"`
	NIK          string `json:"nik" binding:"required,len=16,numeric"`
	TanggalLahir string `json:"tanggal_lahir" binding:"required"`
	Telepon      string `json:"telepon" binding:"required,max=20"`
	JenisKelamin string `json:"jenis_kelamin" binding:"required,oneof=Laki-laki Perempuan"`
	Alamat       string `json:"alamat" binding:"required,max=255"`
}

type RegisterPasienResponse struct {
	PasienID    int    `json:"pasien_id"`
	Email       string `json:"email"`
	NamaLengkap string `json:"nama_lengkap"`
	NIK         string `json:"nik"`
	Message     string `json:"message"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}
