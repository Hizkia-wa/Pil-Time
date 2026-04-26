package main

import (
    "backend/config"
    "backend/internal/adapters/inbound/http"
    "backend/internal/adapters/outbound/persistence"
    "backend/internal/usecase"
    "fmt" // Digunakan di baris 144

    "github.com/gin-gonic/gin"
)

func main() {
    db := config.InitPostgres()

    // admin/nakes repo + usecase + handler
    nakesRepo := persistence.NewNakesRepo(db)
    adminUsecase := usecase.NewAdminUsecase(nakesRepo)
    adminHandler := http.NewAdminHandler(adminUsecase)

    // jadwal repo - declare first since it's used in pasien usecase
    jadwalRepo := persistence.NewJadwalRepo(db)

    // pasien repo + usecase + handler
    pasienRepo := persistence.NewPasienRepo(db)
    pasienUsecase := usecase.NewPasienUsecase(pasienRepo, jadwalRepo)
    pasienHandler := http.NewPasienHandler(pasienUsecase)
    jadwalUsecase := usecase.NewJadwalUsecase(jadwalRepo, pasienRepo)
    jadwalHandler := http.NewJadwalHandler(jadwalUsecase)

    // dashboard repo + usecase + handler
    dashboardUsecase := usecase.NewDashboardUsecase(pasienRepo, jadwalRepo)
    dashboardHandler := http.NewDashboardHandler(dashboardUsecase)

    // obat repo + usecase + handler
    obatRepo := persistence.NewObatRepo(db)
    obatUsecase := usecase.NewObatUsecase(obatRepo)
    obatHandler := http.NewObatHandler(obatUsecase)

    // tracking jadwal repo + usecase + handler
    trackingJadwalRepo := persistence.NewTrackingJadwalRepo(db)
    trackingJadwalUsecase := usecase.NewTrackingJadwalUsecase(trackingJadwalRepo, jadwalRepo, pasienRepo)
    trackingJadwalHandler := http.NewTrackingJadwalHandler(trackingJadwalUsecase)

    // --- TAMBAHAN RUTINITAS DIMULAI ---
    rutinitasRepo := persistence.NewRutinitasRepo(db)
    rutinitasUsecase := usecase.NewRutinitasUsecase(rutinitasRepo)
    rutinitasHandler := http.NewRutinitasHandler(rutinitasUsecase)
    // --- TAMBAHAN RUTINITAS SELESAI ---

    // file handler
    fileHandler := http.NewFileHandler()

    // router - gunakan gin.New() untuk kontrol penuh
    r := gin.New()
    r.Use(gin.Logger())
    r.Use(gin.Recovery())

    // Manual CORS middleware
    r.Use(func(c *gin.Context) {
        origin := c.GetHeader("Origin")
        allowedOrigins := map[string]bool{
            "http://localhost:5173": true,
            "http://localhost:5174": true,
            "http://127.0.0.1:5173": true,
            "http://127.0.0.1:5174": true,
            "http://localhost:3000": true,
            "http://127.0.0.1:3000": true,
        }

        if allowedOrigins[origin] {
            c.Header("Access-Control-Allow-Origin", origin)
        }

        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
        c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, Accept, X-Requested-With, Access-Control-Request-Headers, X-Pasien-ID")
        c.Header("Access-Control-Allow-Credentials", "true")
        c.Header("Access-Control-Max-Age", "86400")

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

    // Admin obat routes (Info Obat)
    r.GET("/api/admin/info-obat", obatHandler.GetAll)
    r.GET("/api/admin/info-obat/:id", obatHandler.GetByID)
    r.POST("/api/admin/info-obat", obatHandler.Create)
    r.PUT("/api/admin/info-obat/:id", obatHandler.Update)
    r.DELETE("/api/admin/info-obat/:id", obatHandler.Delete)

    // File upload routes
    r.POST("/api/upload/image", fileHandler.UploadImage)
    r.POST("/api/upload/image-base64", fileHandler.UploadBase64Image)

    // Static file serving - arahkan ke public/uploads sesuai handler
    r.Static("/uploads", "./public/uploads")

    // Admin jadwal routes
    r.GET("/api/admin/jadwal", jadwalHandler.GetAllJadwal)
    r.GET("/api/admin/jadwal/:id", jadwalHandler.GetJadwalByID)
    r.GET("/api/admin/jadwal/pasien/:pasien_id", jadwalHandler.GetJadwalByPasien)
    r.POST("/api/admin/jadwal", jadwalHandler.CreateJadwal)
    r.PUT("/api/admin/jadwal/:id", jadwalHandler.UpdateJadwal)
    r.DELETE("/api/admin/jadwal/:id", jadwalHandler.DeleteJadwal)

    // Admin tracking jadwal routes
    r.GET("/api/admin/riwayat/statistics", trackingJadwalHandler.GetStatistics)
    r.GET("/api/admin/riwayat", trackingJadwalHandler.GetAll)
    r.GET("/api/admin/riwayat/:id", trackingJadwalHandler.GetByID)
    r.GET("/api/admin/riwayat/pasien/:pasien_id", trackingJadwalHandler.GetByPasienID)
    r.POST("/api/admin/riwayat", trackingJadwalHandler.Create)
    r.PUT("/api/admin/riwayat/:id", trackingJadwalHandler.Update)
    r.DELETE("/api/admin/riwayat/:id", trackingJadwalHandler.Delete)

    // Pasien routes
    r.POST("/api/pasien/register", pasienHandler.Register)
    r.POST("/api/pasien/login", pasienHandler.Login)
    r.POST("/api/pasien/forgot-password", pasienHandler.ForgotPassword)
    r.POST("/api/pasien/verify-reset-code", pasienHandler.VerifyResetCode)
    r.POST("/api/pasien/reset-password", pasienHandler.ResetPassword)

    // Pasien auth group
    pasienAuthGroup := r.Group("/api/pasien")
    pasienAuthGroup.Use(func(c *gin.Context) {
        pasienIDStr := c.GetHeader("X-Pasien-ID")
        if pasienIDStr == "" {
            pasienIDStr = c.Query("pasien_id")
        }

        if pasienIDStr != "" {
            var pasienID int
            _, err := fmt.Sscanf(pasienIDStr, "%d", &pasienID)
            if err == nil {
                c.Set("pasien_id", pasienID)
            }
        }
        c.Next()
    })

    pasienAuthGroup.GET("/dashboard", pasienHandler.GetDashboard)
    pasienAuthGroup.GET("/jadwal", pasienHandler.GetJadwal)
    pasienAuthGroup.GET("/profile", pasienHandler.GetProfile)

    // --- TAMBAHAN ROUTE RUTINITAS ---
    pasienAuthGroup.GET("/rutinitas/streak/:pasien_id", rutinitasHandler.GetStreak)
    pasienAuthGroup.POST("/rutinitas/tracking", rutinitasHandler.UpdateTracking)
    pasienAuthGroup.POST("/rutinitas", rutinitasHandler.Create)
	pasienAuthGroup.DELETE("/rutinitas/:id", rutinitasHandler.Delete)
    // --- SELESAI ---

    r.Run(":8080")
}