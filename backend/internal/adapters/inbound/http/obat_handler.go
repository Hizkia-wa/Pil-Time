package http

import (
	"backend/internal/dto"
	"backend/internal/usecase"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ObatHandler struct {
	usecase *usecase.ObatUsecase
}

func NewObatHandler(u *usecase.ObatUsecase) *ObatHandler {
	return &ObatHandler{u}
}

// GetAll menangani HTTP request untuk mendapatkan semua obat
func (h *ObatHandler) GetAll(c *gin.Context) {
	obats, err := h.usecase.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error:   "FETCH_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": obats,
	})
}

// GetByID menangani HTTP request untuk mendapatkan obat berdasarkan ID
func (h *ObatHandler) GetByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	obat, err := h.usecase.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{
			Error:   "NOT_FOUND",
			Message: "Obat tidak ditemukan",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": obat,
	})
}

// Create menangani HTTP request untuk membuat obat baru
func (h *ObatHandler) Create(c *gin.Context) {
	var req dto.CreateObatDTO

	// Bind JSON request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	// Call usecase create
	resp, err := h.usecase.Create(&req)
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

// Update menangani HTTP request untuk mengupdate obat
func (h *ObatHandler) Update(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	var req dto.UpdateObatDTO

	// Bind JSON request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "VALIDATION_ERROR",
			Message: err.Error(),
		})
		return
	}

	// Call usecase update
	resp, err := h.usecase.Update(id, &req)
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

// Delete menangani HTTP request untuk menghapus obat
func (h *ObatHandler) Delete(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "INVALID_ID",
			Message: "ID harus berupa angka",
		})
		return
	}

	// Call usecase delete
	err = h.usecase.Delete(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error:   "DELETE_ERROR",
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Obat berhasil dihapus",
	})
}
