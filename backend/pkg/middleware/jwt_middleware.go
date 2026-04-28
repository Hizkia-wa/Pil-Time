package middleware

import (
	"backend/pkg/utils"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// JWTNakesMiddleware memvalidasi JWT token untuk admin/nakes
// Digunakan di route /api/admin/* (selain login)
func JWTNakesMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "UNAUTHORIZED",
				"message": "Token tidak ditemukan. Gunakan header Authorization: Bearer <token>",
			})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "UNAUTHORIZED",
				"message": "Format token salah. Gunakan: Bearer <token>",
			})
			c.Abort()
			return
		}

		claims, err := utils.ValidateToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "UNAUTHORIZED",
				"message": "Token tidak valid atau sudah kadaluarsa",
			})
			c.Abort()
			return
		}

		if claims.Role != "admin" {
			c.JSON(http.StatusForbidden, gin.H{
				"error":   "FORBIDDEN",
				"message": "Hanya admin/nakes yang dapat mengakses endpoint ini",
			})
			c.Abort()
			return
		}

		// Inject claims ke context
		c.Set("user_id", claims.ID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role)
		c.Next()
	}
}

// JWTPasienMiddleware memvalidasi JWT token untuk pasien
// Menggantikan PasienAuthMiddleware yang lama (X-Pasien-ID header)
func JWTPasienMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "UNAUTHORIZED",
				"message": "Token tidak ditemukan. Gunakan header Authorization: Bearer <token>",
			})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "UNAUTHORIZED",
				"message": "Format token salah. Gunakan: Bearer <token>",
			})
			c.Abort()
			return
		}

		claims, err := utils.ValidateToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "UNAUTHORIZED",
				"message": "Token tidak valid atau sudah kadaluarsa",
			})
			c.Abort()
			return
		}

		if claims.Role != "pasien" {
			c.JSON(http.StatusForbidden, gin.H{
				"error":   "FORBIDDEN",
				"message": "Hanya pasien yang dapat mengakses endpoint ini",
			})
			c.Abort()
			return
		}

		// Inject pasien_id ke context (kompatibel dengan handler yang sudah ada)
		c.Set("pasien_id", claims.ID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role)
		c.Next()
	}
}
