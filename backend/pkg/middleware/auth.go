package middleware

import (
	"backend/pkg/utils"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// AuthMiddleware - Validasi JWT token
func AuthMiddleware(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Token tidak ditemukan"})
		c.Abort()
		return
	}

	// Extract token dari "Bearer <token>"
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")
	if tokenString == authHeader {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Format token salah"})
		c.Abort()
		return
	}

	claims, err := utils.ValidateToken(tokenString)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Token tidak valid"})
		c.Abort()
		return
	}

	c.Set("user_id", claims.ID)
	c.Set("role", claims.Role)
	c.Set("nama", claims.Nama)
	c.Next()
}

// NakesOnlyMiddleware - Hanya nakes (admin) yang bisa akses
func NakesOnlyMiddleware(c *gin.Context) {
	role, exists := c.Get("role")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "User tidak terautentikasi"})
		c.Abort()
		return
	}

	if role != "nakes" {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "Hanya nakes yang bisa akses"})
		c.Abort()
		return
	}

	c.Next()
}

// PasienOnlyMiddleware - Hanya pasien yang bisa akses
func PasienOnlyMiddleware(c *gin.Context) {
	role, exists := c.Get("role")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "User tidak terautentikasi"})
		c.Abort()
		return
	}

	if role != "pasien" {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "Hanya pasien yang bisa akses"})
		c.Abort()
		return
	}

	c.Next()
}
