package main

import (
	"backend/config"
	"backend/internal/adapters/inbound/http"
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/usecase"
	"fmt"
	"log"

	"backend/internal/domain"

	"github.com/gin-gonic/gin"
)

func main() {
	// 1. DATABASE INIT
	db := config.InitPostgres()

	db.AutoMigrate(
		&domain.ResepObat{},
		&domain.JadwalObat{},
	)
	if db == nil {
		log.Fatal("Gagal mengoneksikan database")
	}

	// 2. DEPENDENCY INJECTION (DI)
	// Repositories
	nakesRepo := persistence.NewNakesRepo(db)
	pasienRepo := persistence.NewPasienRepo(db)
	jadwalRepo := persistence.NewJadwalRepo(db)
	obatRepo := persistence.NewObatRepo(db)
	trackingRepo := persistence.NewTrackingJadwalRepo(db)
	rutinitasRepo := persistence.NewRutinitasRepo(db)
	resepRepo := persistence.NewResepObatRepo(db)
	jadwalObatRepo := persistence.NewJadwalObatRepo(db)

	// Usecases
	adminUC := usecase.NewAdminUsecase(nakesRepo)
	pasienUC := usecase.NewPasienUsecase(pasienRepo, jadwalRepo)
	jadwalUC := usecase.NewJadwalUsecase(jadwalRepo, pasienRepo)
	dashboardUC := usecase.NewDashboardUsecase(pasienRepo, jadwalRepo)
	obatUC := usecase.NewObatUsecase(obatRepo)
	trackingUC := usecase.NewTrackingJadwalUsecase(trackingRepo, jadwalRepo, pasienRepo)
	rutinitasUC := usecase.NewRutinitasUsecase(rutinitasRepo)
	resepJadwalUC := usecase.NewResepJadwalUsecase(resepRepo, jadwalObatRepo, jadwalRepo)

	// Handlers
	adminHandler := http.NewAdminHandler(adminUC)
	pasienHandler := http.NewPasienHandler(pasienUC)
	jadwalHandler := http.NewJadwalHandler(jadwalUC)
	dashboardHandler := http.NewDashboardHandler(dashboardUC)
	obatHandler := http.NewObatHandler(obatUC)
	trackingHandler := http.NewTrackingJadwalHandler(trackingUC)
	rutinitasHandler := http.NewRutinitasHandler(rutinitasUC)
	resepJadwalHandler := http.NewResepJadwalHandler(resepJadwalUC)
	fileHandler := http.NewFileHandler()

	// 3. ROUTER SETUP
	r := gin.New()
	r.SetTrustedProxies(nil)
	r.Use(gin.Logger(), gin.Recovery())
	r.Use(CORSConfig())

	// 4. STATIC FILES (PENTING untuk PWA & Uploads)
	r.Static("/uploads", "./public/uploads")
	r.StaticFile("/manifest.json", "./public/manifest.json")
	r.Static("/img", "./public/img")

	// 5. API ROUTES
	api := r.Group("/api")
	{
		// --- ADMIN ROUTES ---
		admin := api.Group("/admin")
		{
			admin.POST("/login", adminHandler.Login)
			admin.GET("/dashboard", dashboardHandler.GetDashboard)
			admin.GET("/pasien", pasienHandler.GetAll)

			// Admin - Info Obat
			obat := admin.Group("/info-obat")
			{
				obat.GET("", obatHandler.GetAll)
				obat.GET("/:id", obatHandler.GetByID)
				obat.POST("", obatHandler.Create)
				obat.PUT("/:id", obatHandler.Update)
				obat.DELETE("/:id", obatHandler.Delete)
			}

			// Admin - Jadwal
			jadwal := admin.Group("/jadwal")
			{
				jadwal.GET("", jadwalHandler.GetAllJadwal)
				jadwal.GET("/:id", jadwalHandler.GetJadwalByID)
				jadwal.GET("/pasien/:pasien_id", jadwalHandler.GetJadwalByPasien)
				jadwal.POST("", jadwalHandler.CreateJadwal)
				jadwal.PUT("/:id", jadwalHandler.UpdateJadwal)
				jadwal.DELETE("/:id", jadwalHandler.DeleteJadwal)
			}
			admin.POST("/resep-jadwal", resepJadwalHandler.Create)

			// Admin - Tracking/Riwayat
			riwayat := admin.Group("/riwayat")
			{
				riwayat.GET("", trackingHandler.GetAll)
				riwayat.GET("/statistics", trackingHandler.GetStatistics)
				riwayat.GET("/:id", trackingHandler.GetByID)
				riwayat.GET("/pasien/:pasien_id", trackingHandler.GetByPasienID)
				riwayat.POST("", trackingHandler.Create)
				riwayat.PUT("/:id", trackingHandler.Update)
				riwayat.DELETE("/:id", trackingHandler.Delete)
			}
		}

		// --- PASIEN PUBLIC ROUTES ---
		api.POST("/pasien/register", pasienHandler.Register)
		api.POST("/pasien/login", pasienHandler.Login)
		api.POST("/pasien/forgot-password", pasienHandler.ForgotPassword)
		api.POST("/pasien/verify-reset-code", pasienHandler.VerifyResetCode)
		api.POST("/pasien/reset-password", pasienHandler.ResetPassword)

		// --- PASIEN AUTHENTICATED ROUTES ---
		pasienAuth := api.Group("/pasien")
		pasienAuth.Use(PasienAuthMiddleware())
		{
			pasienAuth.GET("/dashboard", pasienHandler.GetDashboard)
			pasienAuth.GET("/jadwal", pasienHandler.GetJadwal)
			pasienAuth.GET("/profile", pasienHandler.GetProfile)

			// Pasien - Rutinitas
			pasienAuth.GET("/rutinitas/streak/:pasien_id", rutinitasHandler.GetStreak)
			pasienAuth.POST("/rutinitas/tracking", rutinitasHandler.UpdateTracking)
			pasienAuth.POST("/rutinitas", rutinitasHandler.Create)
			pasienAuth.DELETE("/rutinitas/:id", rutinitasHandler.Delete)

			// Pasien - Obat Mandiri
			pasienAuth.POST("/obat-mandiri", obatHandler.CreateMandiri)
			pasienAuth.GET("/obat-mandiri", obatHandler.GetAll)
			pasienAuth.GET("/obat-mandiri/:id", obatHandler.GetByID)
			pasienAuth.PUT("/obat-mandiri/:id", obatHandler.Update)
			pasienAuth.DELETE("/obat-mandiri/:id", obatHandler.Delete)
		}

		// --- UPLOAD ROUTES ---
		api.POST("/upload/image", fileHandler.UploadImage)
		api.POST("/upload/image-base64", fileHandler.UploadBase64Image)
	}

	fmt.Println("Pil Time Server running on :8080")
	r.Run(":8080")
}

// MIDDLEWARES
func CORSConfig() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		c.Header("Access-Control-Allow-Origin", origin)
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, Accept, X-Requested-With, X-Pasien-ID")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}

func PasienAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		pasienIDStr := c.GetHeader("X-Pasien-ID")
		if pasienIDStr == "" {
			pasienIDStr = c.Query("pasien_id")
		}

		if pasienIDStr != "" {
			var pasienID int
			if _, err := fmt.Sscanf(pasienIDStr, "%d", &pasienID); err == nil {
				c.Set("pasien_id", pasienID)
			}
		}
		c.Next()
	}
}
