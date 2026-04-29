package dto

// ===== NAKES AUTH =====

type LoginNakesRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type LoginNakesResponse struct {
	Token   string    `json:"token"`
	Message string    `json:"message"`
	Data    NakesData `json:"data"`
}

type NakesData struct {
	NakesID int    `json:"nakes_id"`
	Email   string `json:"email"`
	Nama    string `json:"nama"`
}

// ===== PASIEN AUTH =====

type LoginPasienRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

type LoginPasienResponse struct {
	Token       string `json:"token"`
	PasienID    int    `json:"pasien_id"`
	Email       string `json:"email"`
	NamaLengkap string `json:"nama_lengkap"`
	Message     string `json:"message"`
}

type RegisterPasienRequest struct {
	NamaLengkap  string `json:"nama_lengkap" binding:"required"`
	Email        string `json:"email" binding:"required,email"`
	Password     string `json:"password" binding:"required,min=8"`
	NIK          string `json:"nik" binding:"required"`
	TanggalLahir string `json:"tanggal_lahir" binding:"required"` // YYYY-MM-DD
	TempatLahir  string `json:"tempat_lahir"`
	Telepon      string `json:"telepon"`
	JenisKelamin string `json:"jenis_kelamin"`
	Alamat       string `json:"alamat"`
}

type RegisterPasienResponse struct {
	PasienID    int    `json:"pasien_id"`
	Email       string `json:"email"`
	NamaLengkap string `json:"nama_lengkap"`
	NIK         string `json:"nik"`
	Message     string `json:"message"`
}

// ===== PASSWORD RESET =====

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type ForgotPasswordResponse struct {
	Message string `json:"message"`
}

type VerifyResetCodeRequest struct {
	Email string `json:"email" binding:"required,email"`
	Code  string `json:"code" binding:"required"`
}

type VerifyResetCodeResponse struct {
	Message string `json:"message"`
}

type ResetPasswordRequest struct {
	Email       string `json:"email" binding:"required,email"`
	Code        string `json:"code" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=8"`
}

type ResetPasswordResponse struct {
	Message string `json:"message"`
}

// ===== TOKEN VALIDATION =====

type ValidateTokenResponse struct {
	Valid    bool   `json:"valid"`
	UserID   int    `json:"user_id"`
	Email    string `json:"email"`
	Role     string `json:"role"`
	Message  string `json:"message"`
}

// ===== SHARED =====

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}
