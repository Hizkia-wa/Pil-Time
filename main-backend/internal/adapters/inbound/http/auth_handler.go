package http

import (
	"backend/internal/dto"
	"backend/internal/usecase"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	usecase *usecase.AuthUsecase
}

func NewAuthHandler(u *usecase.AuthUsecase) *AuthHandler {
	return &AuthHandler{u}
}

// ===========================
//         NAKES AUTH
// ===========================

func (h *AuthHandler) LoginNakes(c *gin.Context) {
	var req dto.LoginNakesRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	resp, err := h.usecase.LoginNakes(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{
			Error:   "LOGIN_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ===========================
//        PASIEN AUTH
// ===========================

func (h *AuthHandler) RegisterPasien(c *gin.Context) {
	var req dto.RegisterPasienRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	resp, err := h.usecase.RegisterPasien(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "REGISTRATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, resp)
}

func (h *AuthHandler) LoginPasien(c *gin.Context) {
	var req dto.LoginPasienRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	resp, err := h.usecase.LoginPasien(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{
			Error:   "LOGIN_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ===========================
//       PASSWORD RESET
// ===========================

func (h *AuthHandler) ForgotPassword(c *gin.Context) {
	var req dto.ForgotPasswordRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	resp, err := h.usecase.ForgotPassword(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "FORGOT_PASSWORD_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *AuthHandler) VerifyResetCode(c *gin.Context) {
	var req dto.VerifyResetCodeRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	resp, err := h.usecase.VerifyResetCode(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VERIFY_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req dto.ResetPasswordRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	resp, err := h.usecase.ResetPassword(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "RESET_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ===========================
//       TOKEN VALIDATION
// ===========================

func (h *AuthHandler) ValidateToken(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, dto.ValidateTokenResponse{
			Valid:   false,
			Message: "Token tidak ditemukan",
		})
		return
	}

	tokenString := strings.TrimPrefix(authHeader, "Bearer ")
	if tokenString == authHeader {
		c.JSON(http.StatusUnauthorized, dto.ValidateTokenResponse{
			Valid:   false,
			Message: "Format token salah, gunakan: Bearer <token>",
		})
		return
	}

	resp, err := h.usecase.ValidateToken(tokenString)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error:   "INTERNAL_ERROR",
			Message: err.Error(),
		})
		return
	}

	if !resp.Valid {
		c.JSON(http.StatusUnauthorized, resp)
		return
	}

	c.JSON(http.StatusOK, resp)
}
