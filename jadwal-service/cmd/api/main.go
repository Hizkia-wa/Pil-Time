package main

import (
	"jadwal-service/internal/adapters/inbound/http"
	"jadwal-service/internal/adapters/outbound/persistence"
	"jadwal-service/internal/config"
	"jadwal-service/internal/domain"
	"jadwal-service/internal/usecase"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize database
	db := config.InitPostgres()

	// Auto-migrate domain models
	db.AutoMigrate(
		&domain.ResepObat{},
		&domain.JadwalObat{},
	)

	// Setup repositories
	jadwalRepo := persistence.NewJadwalRepo(db)
	resepObatRepo := persistence.NewResepObatRepo(db)
	jadwalObatRepo := persistence.NewJadwalObatRepo(db)

	// Setup usecases
	jadwalUsecase := usecase.NewJadwalUsecase(jadwalRepo)
	resepJadwalUsecase := usecase.NewResepJadwalUsecase(resepObatRepo, jadwalObatRepo, jadwalRepo)

	// Setup handlers
	jadwalHandler := http.NewJadwalHandler(jadwalUsecase)
	resepJadwalHandler := http.NewResepJadwalHandler(resepJadwalUsecase)

	// Setup router
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// CORS middleware untuk jadwal service
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "Pil Time Jadwal Service is running"})
	})

	// Jadwal routes
	r.GET("/api/jadwal", jadwalHandler.GetAllJadwal)
	r.GET("/api/jadwal/:id", jadwalHandler.GetJadwalByID)
	r.GET("/api/jadwal/pasien/:pasien_id", jadwalHandler.GetJadwalByPasien)
	r.POST("/api/jadwal", jadwalHandler.CreateJadwal)
	r.PUT("/api/jadwal/:id", jadwalHandler.UpdateJadwal)
	r.DELETE("/api/jadwal/:id", jadwalHandler.DeleteJadwal)

	// Resep Jadwal route
	r.POST("/api/resep-jadwal", resepJadwalHandler.Create)

	log.Println("Jadwal Service starting on port 8081...")
	r.Run(":8081")
}
