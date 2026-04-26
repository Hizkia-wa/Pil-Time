package http

import (
	"backend/internal/dto"
	"backend/internal/usecase"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type RutinitasHandler struct {
	usecase *usecase.RutinitasUsecase
}

func NewRutinitasHandler(u *usecase.RutinitasUsecase) *RutinitasHandler {
	return &RutinitasHandler{usecase: u}
}

// Create - Membuat jadwal rutinitas baru
func (h *RutinitasHandler) Create(c *gin.Context) {
	var req dto.CreateRutunitasDTO
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	result, err := h.usecase.Create(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, result)
}

// GetStreak - Mengambil jumlah streak pasien
func (h *RutinitasHandler) GetStreak(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("pasien_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID pasien tidak valid"})
		return
	}

	s, err := h.usecase.GetStreak(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"current_streak": s})
}

// UpdateTracking - Mencatat ceklis rutinitas (Status: done/none)
func (h *RutinitasHandler) UpdateTracking(c *gin.Context) {
	var req dto.CreateTrackingRutunitasDTO
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validasi apakah RutinitasID benar-benar ada di database
	_, err := h.usecase.GetByID(req.RutinitasID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Rutinitas tidak ditemukan"})
		return
	}

	/* CATATAN PERBAIKAN: 
	   Kuncian status "selesai" atau "terlambat" dihapus dari sini.
	   Ini dilakukan agar Flutter bisa melakukan toggle status (check/un-check) 
	   secara fleksibel sesuai permintaan user.
	*/

	err = h.usecase.MarkTracking(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "success",
		"status":  req.Status,
	})
}

// Delete - Menghapus jadwal rutinitas
func (h *RutinitasHandler) Delete(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	err = h.usecase.Delete(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "deleted"})
}