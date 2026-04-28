package utils

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Claims struct {
	ID    int    `json:"id"`
	Email string `json:"email"`
	Role  string `json:"role"`
	jwt.RegisteredClaims
}

const defaultSecret = "your-secret-key-change-this-in-production"

// getSecret selalu membaca JWT_SECRET dari environment saat runtime.
// Ini memastikan secret yang dipakai backend sama dengan auth-service,
// terlepas dari kapan godotenv.Load() dipanggil.
func getSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return []byte(defaultSecret)
	}
	return []byte(secret)
}

// GenerateToken membuat JWT token baru untuk admin/nakes
func GenerateToken(nakesID int, email string) (string, error) {
	claims := Claims{
		ID:    nakesID,
		Email: email,
		Role:  "admin",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(getSecret())
}

// GeneratePasienToken membuat JWT token untuk pasien
func GeneratePasienToken(pasienID int, email string) (string, error) {
	claims := Claims{
		ID:    pasienID,
		Email: email,
		Role:  "pasien",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(getSecret())
}

// ValidateToken memvalidasi JWT token — selalu pakai secret terkini dari env
func ValidateToken(tokenString string) (*Claims, error) {
	claims := &Claims{}

	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return getSecret(), nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}
