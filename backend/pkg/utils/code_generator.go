package utils

import (
	"math/rand"
)

// GenerateResetCode generates a random 6-digit code
func GenerateResetCode() string {
	code := rand.Intn(900000) + 100000
	return string(rune(code%10+48)) + string(rune((code/10)%10+48)) + string(rune((code/100)%10+48)) + string(rune((code/1000)%10+48)) + string(rune((code/10000)%10+48)) + string(rune(code/100000+48))
}

// GenerateResetCodeSimple generates a random 6-digit code (simpler approach)
func GenerateResetCodeSimple() string {
	const charset = "0123456789"
	b := make([]byte, 6)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return string(b)
}
