package http

import (
	"jadwal-service/internal/dto"
	"jadwal-service/internal/usecase"
	"net/http"

	"github.com/gin-gonic/gin"
)

type ResepJadwalHandler struct {
	usecase *usecase.ResepJadwalUsecase
}

func NewResepJadwalHandler(u *usecase.ResepJadwalUsecase) *ResepJadwalHandler {
	return &ResepJadwalHandler{u}
}

func (h *ResepJadwalHandler) Create(c *gin.Context) {
	var req dto.CreateResepWithJadwalDTO

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	if err := h.usecase.Create(&req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "berhasil disimpan",
	})
}
