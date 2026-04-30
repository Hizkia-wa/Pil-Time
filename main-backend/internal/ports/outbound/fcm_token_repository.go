package outbound

// FcmTokenRepository defines operations for storing FCM device tokens.
type FcmTokenRepository interface {
	// Upsert menyimpan atau memperbarui token pasien
	Upsert(pasienID uint, token string) error
	// GetByPasienID mengambil token untuk dikirim notifikasi
	GetByPasienID(pasienID uint) (string, error)
}
