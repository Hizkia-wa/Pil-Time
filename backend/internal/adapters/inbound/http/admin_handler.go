package http

import (
	"backend/internal/dto"
	"backend/internal/usecase"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	adminUsecase *usecase.AdminUsecase
}

func NewAdminHandler(u *usecase.AdminUsecase) *AdminHandler {
	return &AdminHandler{u}
}

// Login menangani HTTP request untuk login admin/nakes
func (h *AdminHandler) Login(c *gin.Context) {
	var req dto.AdminLoginRequest

	// Bind JSON request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	// Call usecase login
	resp, err := h.adminUsecase.Login(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{
			Error:   "LOGIN_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}
