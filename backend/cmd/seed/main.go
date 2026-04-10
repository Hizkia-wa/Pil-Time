package main

import (
	"backend/config"
	"backend/internal/domain"
	"backend/pkg/utils"
	"log"
)

func main() {
	db := config.InitPostgres()

	// Hash password untuk admin default
	hashedPassword, err := utils.HashPassword("admin12345")
	if err != nil {
		log.Fatal("Gagal hash password:", err)
	}

	// Data admin default
	adminUser := &domain.Nakes{
		Nama:      "Admin Sahabat Sehat",
		Email:     "admin@sahabatsehat.com",
		Password:  hashedPassword,
		JenisIlmu: "Umum",
		Status:    "active",
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
	log.Println("Email: admin@sahabatsehat.com")
	log.Println("Password: admin12345")
}
