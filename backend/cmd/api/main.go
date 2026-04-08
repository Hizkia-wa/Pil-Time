package main

import (
	"backend/config"
	"backend/internal/adapters/inbound/http"
	"backend/internal/adapters/outbound/firebase"
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

	// 🔥 Firebase
	firebaseService, err := firebase.NewFirebaseService()
	if err != nil {
		panic(err)
	}

	notifUsecase := usecase.NewNotifUsecase(firebaseService)

	// router
	r := gin.Default()

	r.POST("/pasien/register", handler.Register)

	// contoh endpoint test notif
	r.GET("/test-notif", func(c *gin.Context) {
		err := notifUsecase.SendReminder("TOKEN_DEVICE")
		if err != nil {
			c.JSON(500, gin.H{"error": err.Error()})
			return
		}
		c.JSON(200, gin.H{"message": "notif sent"})
	})

	r.Run(":8080")
}