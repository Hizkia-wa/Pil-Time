package persistence

import (
	"backend/internal/domain"
	"errors"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type FcmTokenRepo struct {
	db *gorm.DB
}

func NewFcmTokenRepo(db *gorm.DB) *FcmTokenRepo {
	return &FcmTokenRepo{db: db}
}

// Upsert menyimpan token baru atau update token lama jika pasienID sudah ada.
func (r *FcmTokenRepo) Upsert(pasienID uint, token string) error {
	fcmToken := domain.FcmToken{
		PasienID: pasienID,
		Token:    token,
	}
	result := r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "pasien_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"token", "updated_at"}),
	}).Create(&fcmToken)
	return result.Error
}

// GetByPasienID mengambil FCM token device milik pasien.
func (r *FcmTokenRepo) GetByPasienID(pasienID uint) (string, error) {
	var fcmToken domain.FcmToken
	result := r.db.Where("pasien_id = ?", pasienID).First(&fcmToken)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return "", nil // pasien belum daftar token — tidak error
		}
		return "", result.Error
	}
	return fcmToken.Token, nil
}
