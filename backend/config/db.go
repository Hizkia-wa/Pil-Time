package config

import (
	"backend/internal/domain"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitPostgres() *gorm.DB {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_SSLMODE"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Gagal koneksi database!")
	}

	log.Println("Database connected!")

	// Drop table lama jika ada (untuk development)
	if db.Migrator().HasTable(&domain.Pasien{}) {
		if err := db.Migrator().DropTable(&domain.Pasien{}); err != nil {
			log.Println("Warning: gagal drop table lama:", err)
		} else {
			log.Println("Dropped old pasien table")
		}
	}

	// Auto-migrate schema
	if err := db.AutoMigrate(&domain.Pasien{}); err != nil {
		panic("Gagal auto-migrate: " + err.Error())
	}
	log.Println("Database migration completed!")

	return db
}
