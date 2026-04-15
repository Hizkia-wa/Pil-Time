package config

import (
	"fmt"
	"log"
	"os"

	"jadwal-service/internal/domain"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitPostgres() *gorm.DB {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file tidak ditemukan, menggunakan default config")
	}

	// Gunakan database yang SAMA dengan backend utama
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		getEnv("DB_HOST", "localhost"),
		getEnv("DB_USER", "postgres"),
		getEnv("DB_PASSWORD", "password"),
		getEnv("DB_NAME", "backend"),
		getEnv("DB_PORT", "5432"),
		getEnv("DB_SSLMODE", "disable"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Gagal koneksi database jadwal service!")
	}

	log.Println("Jadwal Service connected to shared database!")

	// Auto migrate - hanya structure check, tidak bakal buat ulang jika sudah ada
	if err := db.AutoMigrate(&domain.Jadwal{}); err != nil {
		panic("Gagal auto-migrate jadwal: " + err.Error())
	}
	log.Println("Jadwal Service migration check completed!")

	return db
}

func getEnv(key, defaultVal string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultVal
}
