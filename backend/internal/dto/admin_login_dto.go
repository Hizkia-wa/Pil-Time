package dto

type AdminLoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

type AdminUser struct {
	NakesID int    `json:"nakes_id"`
	Email   string `json:"email"`
	Nama    string `json:"nama"`
}

type AdminLoginData struct {
	Token string    `json:"token"`
	User  AdminUser `json:"user"`
}

type AdminLoginResponse struct {
	Data    AdminLoginData `json:"data"`
	Message string         `json:"message"`
}
