package main

import (
	"auth-service/config"
	"auth-service/internal/adapters/inbound/http"
	"auth-service/internal/adapters/outbound/persistence"
	"auth-service/internal/usecase"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 1. DATABASE INIT
	db := config.InitPostgres()

	// 2. DEPENDENCY INJECTION
	// Repositories
	nakesRepo := persistence.NewNakesRepo(db)
	pasienRepo := persistence.NewPasienRepo(db)

	// Usecases
	authUC := usecase.NewAuthUsecase(nakesRepo, pasienRepo)

	// Handlers
	authHandler := http.NewAuthHandler(authUC)

	// 3. ROUTER SETUP
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())
	r.Use(corsMiddleware())

	// 4. HEALTH CHECK
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "Pil-Time Auth Service is running", "port": "8081"})
	})

	// 5. AUTH ROUTES
	auth := r.Group("/auth")
	{
		// Nakes (Admin) Auth
		nakes := auth.Group("/nakes")
		{
			nakes.POST("/login", authHandler.LoginNakes)
		}

		// Pasien Auth
		pasien := auth.Group("/pasien")
		{
			pasien.POST("/register", authHandler.RegisterPasien)
			pasien.POST("/login", authHandler.LoginPasien)
			pasien.POST("/forgot-password", authHandler.ForgotPassword)
			pasien.POST("/verify-reset-code", authHandler.VerifyResetCode)
			pasien.POST("/reset-password", authHandler.ResetPassword)
		}

		// Token Validation (dipakai oleh service lain secara internal)
		auth.GET("/validate", authHandler.ValidateToken)
	}

	log.Println("Auth Service starting on port :8081...")
	if err := r.Run(":8081"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		c.Header("Access-Control-Allow-Origin", origin)
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, Accept")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}
