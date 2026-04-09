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

	// admin/nakes repo + usecase + handler
	nakesRepo := persistence.NewNakesRepo(db)
	adminUsecase := usecase.NewAdminUsecase(nakesRepo)
	adminHandler := http.NewAdminHandler(adminUsecase)

	// pasien repo + usecase + handler
	pasienRepo := persistence.NewPasienRepo(db)
	pasienUsecase := usecase.NewPasienUsecase(pasienRepo)
	pasienHandler := http.NewPasienHandler(pasienUsecase)

	// jadwal repo + usecase + handler
	jadwalRepo := persistence.NewJadwalRepo(db)
	jadwalUsecase := usecase.NewJadwalUsecase(jadwalRepo, pasienRepo)
	jadwalHandler := http.NewJadwalHandler(jadwalUsecase)

	// dashboard repo + usecase + handler
	dashboardUsecase := usecase.NewDashboardUsecase(pasienRepo, jadwalRepo)
	dashboardHandler := http.NewDashboardHandler(dashboardUsecase)

	// router - gunakan gin.New() untuk kontrol penuh
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// Manual CORS middleware - lebih reliable
	r.Use(func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		// Allow specific origins
		allowedOrigins := map[string]bool{
			"http://localhost:5173": true,
			"http://localhost:5174": true, // Vite sering pakai port berbeda
			"http://127.0.0.1:5173": true,
			"http://127.0.0.1:5174": true,
			"http://localhost:3000": true,
			"http://127.0.0.1:3000": true,
		}

		if allowedOrigins[origin] {
			c.Header("Access-Control-Allow-Origin", origin)
		}

		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, Accept, X-Requested-With, Access-Control-Request-Headers")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400")

		// Handle preflight
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Admin routes
	r.POST("/api/admin/login", adminHandler.Login)
	r.GET("/api/admin/dashboard", dashboardHandler.GetDashboard)

	// Admin pasien routes
	r.GET("/api/admin/pasien", pasienHandler.GetAll)

	// Admin jadwal routes
	r.GET("/api/admin/jadwal", jadwalHandler.GetAllJadwal)
	r.GET("/api/admin/jadwal/:id", jadwalHandler.GetJadwalByID)
	r.GET("/api/admin/jadwal/pasien/:pasien_id", jadwalHandler.GetJadwalByPasien)
	r.POST("/api/admin/jadwal", jadwalHandler.CreateJadwal)
	r.PUT("/api/admin/jadwal/:id", jadwalHandler.UpdateJadwal)
	r.DELETE("/api/admin/jadwal/:id", jadwalHandler.DeleteJadwal)

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
