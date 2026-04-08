package main

import (
	"backend/config"
	"backend/internal/adapters/inbound/http"
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/usecase"

	"github.com/gin-gonic/gin"
)

func main() {
	db := config.InitPostgres()

	// repo + usecase + handler
	repo := persistence.NewPasienRepo(db)
	pasienUsecase := usecase.NewPasienUsecase(repo)
	handler := http.NewPasienHandler(pasienUsecase)

	// router
	r := gin.Default()

	r.POST("/pasien/register", handler.Register)
	r.POST("/pasien/login", handler.Login)
	r.POST("/pasien/forgot-password", handler.ForgotPassword)
	r.POST("/pasien/verify-reset-code", handler.VerifyResetCode)
	r.POST("/pasien/reset-password", handler.ResetPassword)

	// TODO: Add Firebase notification later
	// firebaseService, err := firebase.NewFirebaseService()
	// notifUsecase := usecase.NewNotifUsecase(firebaseService)

	r.Run(":8080")
}
