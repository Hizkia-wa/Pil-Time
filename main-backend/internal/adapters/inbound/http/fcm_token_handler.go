package http

import (
	"backend/internal/ports/outbound"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type FcmTokenHandler struct {
	repo outbound.FcmTokenRepository
}

func NewFcmTokenHandler(repo outbound.FcmTokenRepository) *FcmTokenHandler {
	return &FcmTokenHandler{repo: repo}
}

type registerTokenRequest struct {
	Token string `json:"token" binding:"required"`
}

// RegisterToken menyimpan FCM device token pasien ke database.
// Dipanggil dari Flutter saat app start / login.
// Route: POST /api/pasien/fcm-token
func (h *FcmTokenHandler) RegisterToken(c *gin.Context) {
	// Ambil pasien_id dari JWT claims (sudah diset oleh JWTPasienMiddleware)
	pasienIDRaw, exists := c.Get("pasien_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var pasienID uint
	switch v := pasienIDRaw.(type) {
	case float64:
		pasienID = uint(v)
	case uint:
		pasienID = v
	case int:
		pasienID = uint(v)
	case string:
		id, err := strconv.Atoi(v)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "pasien_id tidak valid"})
			return
		}
		pasienID = uint(id)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "pasien_id tidak valid"})
		return
	}

	var req registerTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "token wajib diisi"})
		return
	}

	if err := h.repo.Upsert(pasienID, req.Token); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "gagal menyimpan token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "FCM token berhasil disimpan"})
}
