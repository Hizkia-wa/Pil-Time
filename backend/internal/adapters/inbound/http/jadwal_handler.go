package http

import (
	"backend/internal/dto"
	"backend/internal/usecase"
	"fmt"
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

// GetAllJadwal menangani HTTP request untuk mendapatkan semua jadwal
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

// GetJadwalByID menangani HTTP request untuk mendapatkan jadwal berdasarkan ID
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

// GetJadwalByPasien menangani HTTP request untuk mendapatkan jadwal berdasarkan pasien
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

// CreateJadwal menangani HTTP request untuk membuat jadwal baru
func (h *JadwalHandler) CreateJadwal(c *gin.Context) {
	var req dto.CreateJadwalDTO

	// Bind JSON request
	if err := c.ShouldBindJSON(&req); err != nil {
		// Log the actual error for debugging
		fmt.Println("VALIDATION ERROR:", err.Error())
		fmt.Println("Request body:", c.Request.Body)

		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	// Call usecase create
	resp, err := h.usecase.CreateJadwal(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "CREATE_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"data": resp,
	})
}

// UpdateJadwal menangani HTTP request untuk mengupdate jadwal
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

	// Bind JSON request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	// Call usecase update
	resp, err := h.usecase.UpdateJadwal(id, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "UPDATE_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": resp,
	})
}

// DeleteJadwal menangani HTTP request untuk menghapus jadwal
func (h *JadwalHandler) DeleteJadwal(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	// Call usecase delete
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
