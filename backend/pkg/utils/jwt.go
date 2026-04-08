package utils

import (
	"errors"
)

type Claims struct {
	ID   uint
	Role string
	Nama string
}

func ValidateToken(token string) (*Claims, error) {
	// sementara dummy dulu (biar jalan)
	if token == "" {
		return nil, errors.New("invalid token")
	}

	return &Claims{
		ID:   1,
		Role: "pasien",
		Nama: "dummy",
	}, nil
}