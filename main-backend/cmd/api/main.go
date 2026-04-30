package main

import (
	"backend/config"
	inboundHttp "backend/internal/adapters/inbound/http"
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/domain"
	"backend/internal/usecase"
	"backend/pkg/fcm"
	"backend/pkg/middleware"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 1. DATABASE INIT
	db := config.InitPostgres()

	db.AutoMigrate(
		&domain.ResepObat{},
		&domain.JadwalObat{},
		&domain.FcmToken{}, // FCM device tokens
	)
	if db == nil {
		log.Fatal("Gagal mengoneksikan database")
	}

	// Init Firebase Admin SDK untuk FCM
	if err := fcm.Init("serviceAccountKey.json"); err != nil {
		log.Printf("[WARNING] Firebase init gagal: %v — FCM notifikasi tidak akan berfungsi", err)
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
	fcmTokenRepo := persistence.NewFcmTokenRepo(db)

	// Usecases
	adminUC := usecase.NewAdminUsecase(nakesRepo)
	pasienUC := usecase.NewPasienUsecase(pasienRepo, jadwalRepo)
	jadwalUC := usecase.NewJadwalUsecase(jadwalRepo, pasienRepo, fcmTokenRepo)
	dashboardUC := usecase.NewDashboardUsecase(pasienRepo, jadwalRepo)
	obatUC := usecase.NewObatUsecase(obatRepo)
	trackingUC := usecase.NewTrackingJadwalUsecase(trackingRepo, jadwalRepo, pasienRepo)
	rutinitasUC := usecase.NewRutinitasUsecase(rutinitasRepo)
	resepJadwalUC := usecase.NewResepJadwalUsecase(resepRepo, jadwalObatRepo, jadwalRepo)

	// Handlers
	adminHandler := inboundHttp.NewAdminHandler(adminUC)
	pasienHandler := inboundHttp.NewPasienHandler(pasienUC)
	jadwalHandler := inboundHttp.NewJadwalHandler(jadwalUC)
	dashboardHandler := inboundHttp.NewDashboardHandler(dashboardUC)
	obatHandler := inboundHttp.NewObatHandler(obatUC)
	trackingHandler := inboundHttp.NewTrackingJadwalHandler(trackingUC)
	rutinitasHandler := inboundHttp.NewRutinitasHandler(rutinitasUC)
	resepJadwalHandler := inboundHttp.NewResepJadwalHandler(resepJadwalUC)
	fileHandler := inboundHttp.NewFileHandler()
	fcmTokenHandler := inboundHttp.NewFcmTokenHandler(fcmTokenRepo)

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
			// Login tidak butuh middleware JWT
			admin.POST("/login", adminHandler.Login)

			// Semua route admin lainnya diproteksi JWT nakes
			adminProtected := admin.Group("")
			adminProtected.Use(middleware.JWTNakesMiddleware())
			{
				adminProtected.GET("/dashboard", dashboardHandler.GetDashboard)
				adminProtected.GET("/pasien", pasienHandler.GetAll)

				// Admin - Info Obat
				obat := adminProtected.Group("/info-obat")
				{
					obat.GET("", obatHandler.GetAll)
					obat.GET("/:id", obatHandler.GetByID)
					obat.POST("", obatHandler.Create)
					obat.PUT("/:id", obatHandler.Update)
					obat.DELETE("/:id", obatHandler.Delete)
				}

				// Admin - Jadwal
				jadwal := adminProtected.Group("/jadwal")
				{
					jadwal.GET("", jadwalHandler.GetAllJadwal)
					jadwal.GET("/:id", jadwalHandler.GetJadwalByID)
					jadwal.GET("/pasien/:pasien_id", jadwalHandler.GetJadwalByPasien)
					jadwal.POST("", jadwalHandler.CreateJadwal)
					jadwal.PUT("/:id", jadwalHandler.UpdateJadwal)
					jadwal.DELETE("/:id", jadwalHandler.DeleteJadwal)
				}
				adminProtected.POST("/resep-jadwal", resepJadwalHandler.Create)

				// Admin - Tracking/Riwayat
				riwayat := adminProtected.Group("/riwayat")
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
		}

		// --- PASIEN AUTHENTICATED ROUTES ---
		// Semua route pasien diproteksi JWT pasien (dari auth-service)
		pasienAuth := api.Group("/pasien")
		pasienAuth.Use(middleware.JWTPasienMiddleware())
		{
			pasienAuth.GET("/dashboard", pasienHandler.GetDashboard)
			pasienAuth.GET("/jadwal", pasienHandler.GetJadwal)
			pasienAuth.GET("/profile", pasienHandler.GetProfile)

			// Pasien - Rutinitas
			pasienAuth.GET("/rutinitas", rutinitasHandler.GetAllForPasien)
			pasienAuth.GET("/rutinitas/streak/:pasien_id", rutinitasHandler.GetStreak)
			pasienAuth.POST("/rutinitas/tracking", rutinitasHandler.UpdateTracking)
			pasienAuth.POST("/rutinitas", rutinitasHandler.Create)
			pasienAuth.DELETE("/rutinitas/:id", rutinitasHandler.Delete)

			// Pasien - Riwayat Kepatuhan (pasien melihat/mencatat riwayatnya sendiri)
			pasienAuth.GET("/riwayat", trackingHandler.GetMyRiwayat)
			pasienAuth.POST("/riwayat", trackingHandler.CreateMyRiwayat)

			// Pasien - FCM Token Registration
			pasienAuth.POST("/fcm-token", fcmTokenHandler.RegisterToken)

			// Pasien - Obat Mandiri
			pasienAuth.POST("/obat-mandiri", obatHandler.CreateMandiri)
			pasienAuth.GET("/obat-mandiri", obatHandler.GetAllForPasien)
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

// CORSConfig mengatur CORS untuk semua request
func CORSConfig() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		c.Header("Access-Control-Allow-Origin", origin)
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, Accept, X-Requested-With")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}
