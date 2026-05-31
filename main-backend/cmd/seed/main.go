package main

import (
	"backend/config"
	"backend/internal/domain"
	"backend/pkg/utils"
	"log"
	"os"
)

func main() {
	db := config.InitPostgres()

	// Ambil konfigurasi admin default dari environment variables
	adminName := os.Getenv("DEFAULT_ADMIN_NAME")
	if adminName == "" {
		adminName = "Admin Sahabat Sehat"
	}

	adminEmail := os.Getenv("DEFAULT_ADMIN_EMAIL")
	if adminEmail == "" {
		adminEmail = "admin@sahabatsehat.com"
	}

	adminPassword := os.Getenv("DEFAULT_ADMIN_PASSWORD")
	if adminPassword == "" {
		adminPassword = "admin12345" // fallback default aman untuk development lokal
	}

	// Hash password untuk admin default
	hashedPassword, err := utils.HashPassword(adminPassword)
	if err != nil {
		log.Fatal("Gagal hash password:", err)
	}

	// Data admin default
	adminUser := &domain.Nakes{
		Nama:         adminName,
		Email:        adminEmail,
		Password:     hashedPassword,
		NIK:          "0000000000000000",
		JenisKelamin: "L",
	}

	// Check if admin already exists
	var existingAdmin domain.Nakes
	if err := db.Where("email = ?", adminUser.Email).First(&existingAdmin).Error; err == nil {
		log.Println("Admin user sudah terdaftar")
		return
	}

	// Create admin user
	if err := db.Create(adminUser).Error; err != nil {
		log.Fatal("Gagal membuat admin user:", err)
	}

	log.Println("Admin user berhasil dibuat!")
	log.Printf("Email: %s\n", adminUser.Email)
	log.Println("Password: [DISEMBUNYIKAN - Diambil dari .env]")
}
