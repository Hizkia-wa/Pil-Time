package dto

type LoginPasienRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

type LoginPasienResponse struct {
	Token       string `json:"token,omitempty"`
	PasienID    int    `json:"pasien_id"`
	Email       string `json:"email"`
	NamaLengkap string `json:"nama_lengkap"`
	Message     string `json:"message"`
}
