package main

import (
	"backend/config"
	"backend/internal/adapters/inbound/http"
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/usecase"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	db := config.InitPostgres()

	// admin/nakes repo + usecase + handler
	nakesRepo := persistence.NewNakesRepo(db)
	adminUsecase := usecase.NewAdminUsecase(nakesRepo)
	adminHandler := http.NewAdminHandler(adminUsecase)

	// pasien repo + usecase + handler
	pasienRepo := persistence.NewPasienRepo(db)
	pasienUsecase := usecase.NewPasienUsecase(pasienRepo)
	pasienHandler := http.NewPasienHandler(pasienUsecase)

	// router
	r := gin.Default()

	// CORS configuration
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:5173", "http://localhost:3000", "http://127.0.0.1:5173"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Content-Type", "Authorization"}
	config.AllowCredentials = true
	r.Use(cors.New(config))

	// Admin routes
	r.POST("/api/admin/login", adminHandler.Login)

	// Pasien routes
	r.POST("/api/pasien/register", pasienHandler.Register)
	r.POST("/api/pasien/login", pasienHandler.Login)
	r.POST("/api/pasien/forgot-password", pasienHandler.ForgotPassword)
	r.POST("/api/pasien/verify-reset-code", pasienHandler.VerifyResetCode)
	r.POST("/api/pasien/reset-password", pasienHandler.ResetPassword)

	// TODO: Add Firebase notification later
	// firebaseService, err := firebase.NewFirebaseService()
	// notifUsecase := usecase.NewNotifUsecase(firebaseService)

	r.Run(":8080")
}
