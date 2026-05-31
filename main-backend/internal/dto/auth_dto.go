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

// ===== TOKEN VALIDATION =====

type ValidateTokenResponse struct {
	Valid    bool   `json:"valid"`
	UserID   int    `json:"user_id"`
	Email    string `json:"email"`
	Role     string `json:"role"`
	Message  string `json:"message"`
}
