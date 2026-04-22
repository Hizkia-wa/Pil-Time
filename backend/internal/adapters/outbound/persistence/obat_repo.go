package persistence

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"gorm.io/gorm"
)

var _ outbound.ObatRepository = (*obatRepo)(nil)

type obatRepo struct {
	db *gorm.DB
}

func NewObatRepo(db *gorm.DB) outbound.ObatRepository {
	return &obatRepo{db}
}

func (r *obatRepo) GetAll() ([]domain.Obat, error) {
	var data []domain.Obat
	err := r.db.Find(&data).Error
	return data, err
}

func (r *obatRepo) GetByID(id int) (*domain.Obat, error) {
	var obat domain.Obat
	err := r.db.First(&obat, id).Error
	return &obat, err
}

func (r *obatRepo) GetByName(name string) (*domain.Obat, error) {
	var obat domain.Obat
	err := r.db.Where("nama_obat = ?", name).First(&obat).Error
	return &obat, err
}

func (r *obatRepo) Create(o *domain.Obat) (*domain.Obat, error) {
	err := r.db.Create(o).Error
	return o, err
}

func (r *obatRepo) Update(id int, o *domain.Obat) (*domain.Obat, error) {
	err := r.db.Model(&domain.Obat{}).Where("obat_id = ?", id).Updates(o).Error
	if err != nil {
		return nil, err
	}
	return r.GetByID(id)
}

func (r *obatRepo) Delete(id int) error {
	return r.db.Delete(&domain.Obat{}, id).Error
}

// --- TAMBAHKAN METHOD INI UNTUK MENGHILANGKAN ERROR ---
func (r *obatRepo) Count() (int64, error) {
	var count int64
	err := r.db.Model(&domain.Obat{}).Count(&count).Error
	return count, err
}
// ------------------------------------------------------

// Mapper fiks sesuai tabel SQL (6 Kolom Utama)
func ObatToResponseDTO(obat *domain.Obat) *dto.ObatResponseDTO {
	if obat == nil {
		return nil
	}

	return &dto.ObatResponseDTO{
		ObatID:          obat.ObatID,
		NamaObat:        obat.NamaObat,
		Fungsi:          obat.Fungsi,
		AturanPemakaian: obat.AturanPemakaian,
		Pantangan:       obat.Pantangan,
		Gambar:          obat.Gambar,
		CreatedAt:       obat.CreatedAt,
		UpdatedAt:       obat.UpdatedAt,
	}
}