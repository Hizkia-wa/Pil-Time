package http

import (
	"jadwal-service/internal/dto"
	"jadwal-service/internal/usecase"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type JadwalHandler struct {
	usecase *usecase.JadwalUsecase
}

func NewJadwalHandler(u *usecase.JadwalUsecase) *JadwalHandler {
	return &JadwalHandler{u}
}

func (h *JadwalHandler) GetAllJadwal(c *gin.Context) {
	jadwals, err := h.usecase.GetAllJadwal()
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error:   "FETCH_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": jadwals,
	})
}

func (h *JadwalHandler) GetJadwalByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	jadwal, err := h.usecase.GetJadwalByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{
			Error:   "NOT_FOUND",
			Message: "Jadwal tidak ditemukan",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": jadwal,
	})
}

func (h *JadwalHandler) GetJadwalByPasien(c *gin.Context) {
	pasienID, err := strconv.Atoi(c.Param("pasien_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "Pasien ID harus berupa angka",
		})
		return
	}

	jadwals, err := h.usecase.GetJadwalByPasien(pasienID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error:   "FETCH_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": jadwals,
	})
}

func (h *JadwalHandler) CreateJadwal(c *gin.Context) {
	var req dto.CreateJadwalDTO

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	jadwal, err := h.usecase.CreateJadwal(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "CREATE_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"data":    jadwal,
		"message": "Jadwal berhasil dibuat",
	})
}

func (h *JadwalHandler) UpdateJadwal(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	var req dto.UpdateJadwalDTO
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	jadwal, err := h.usecase.UpdateJadwal(id, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "UPDATE_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":    jadwal,
		"message": "Jadwal berhasil diupdate",
	})
}

func (h *JadwalHandler) DeleteJadwal(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	err = h.usecase.DeleteJadwal(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "DELETE_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Jadwal berhasil dihapus",
	})
}
