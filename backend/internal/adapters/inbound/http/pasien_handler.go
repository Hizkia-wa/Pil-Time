package http

import (
	"net/http"
	"backend/internal/domain"
	"backend/internal/usecase"

	"github.com/gin-gonic/gin"
)

type PasienHandler struct {
	usecase *usecase.PasienUsecase
}

func NewPasienHandler(u *usecase.PasienUsecase) *PasienHandler {
	return &PasienHandler{u}
}

func (h *PasienHandler) Register(c *gin.Context) {
	var input struct {
		Nama  string `json:"nama"`
		Email string `json:"email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	pasien := domain.Pasien{
		Nama:  input.Nama,
		Email: input.Email,
	}

	err := h.usecase.Register(&pasien)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, pasien)
}