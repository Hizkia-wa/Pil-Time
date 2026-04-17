package usecase

import (
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"encoding/json"
	"errors"
)

type ObatUsecase struct {
	repo outbound.ObatRepository
}

func NewObatUsecase(r outbound.ObatRepository) *ObatUsecase {
	return &ObatUsecase{repo: r}
}

// GetAll mendapatkan semua obat
func (u *ObatUsecase) GetAll() ([]dto.ObatResponseDTO, error) {
	obats, err := u.repo.GetAll()
	if err != nil {
		return nil, err
	}

	var responses []dto.ObatResponseDTO
	for _, obat := range obats {
		responses = append(responses, *persistence.ObatToResponseDTO(&obat))
	}
	return responses, nil
}

// GetByID mendapatkan obat berdasarkan ID
func (u *ObatUsecase) GetByID(id int) (*dto.ObatResponseDTO, error) {
	obat, err := u.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	if obat == nil || obat.ObatID == 0 {
		return nil, errors.New("obat tidak ditemukan")
	}
	return persistence.ObatToResponseDTO(obat), nil
}

// Create membuat obat baru
func (u *ObatUsecase) Create(req *dto.CreateObatDTO) (*dto.ObatResponseDTO, error) {
	// Validate input
	if req.NamaObat == "" {
		return nil, errors.New("nama obat tidak boleh kosong")
	}
	if req.KategoriIndikasi == "" {
		return nil, errors.New("kategori indikasi tidak boleh kosong")
	}
	if req.Fungsi == "" {
		return nil, errors.New("fungsi obat tidak boleh kosong")
	}
	if req.AturanPenggunaan == "" {
		return nil, errors.New("aturan penggunaan tidak boleh kosong")
	}
	if req.Perhatian == "" {
		return nil, errors.New("perhatian tidak boleh kosong")
	}
	if len(req.WaktuKonsumsi) == 0 {
		return nil, errors.New("waktu konsumsi harus dipilih minimal 1")
	}

	// Cek jika obat dengan nama yang sama sudah ada
	existing, _ := u.repo.GetByName(req.NamaObat)
	if existing != nil && existing.ObatID != 0 {
		return nil, errors.New("obat dengan nama tersebut sudah ada")
	}

	// Convert WaktuKonsumsi slice to JSON string
	waktuJSON, _ := json.Marshal(req.WaktuKonsumsi)

	// Create domain object with all fields
	obat := &domain.Obat{
		NamaObat:         req.NamaObat,
		KategoriIndikasi: req.KategoriIndikasi,
		FrekuensiMin:     req.FrekuensiMin,
		FrekuensiMax:     req.FrekuensiMax,
		DurasiMin:        req.DurasiMin,
		DurasiMax:        req.DurasiMax,
		WaktuKonsumsi:    string(waktuJSON),
		Fungsi:           req.Fungsi,
		AturanPenggunaan: req.AturanPenggunaan,
		Perhatian:        req.Perhatian,
		Gambar:           req.Gambar,
	}

	// Save to database
	result, err := u.repo.Create(obat)
	if err != nil {
		return nil, errors.New("gagal menyimpan data obat")
	}

	return persistence.ObatToResponseDTO(result), nil
}

// Update memperbarui data obat
func (u *ObatUsecase) Update(id int, req *dto.UpdateObatDTO) (*dto.ObatResponseDTO, error) {
	// Cek obat ada atau tidak
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil || existing.ObatID == 0 {
		return nil, errors.New("obat tidak ditemukan")
	}

	// Update fields yang tidak kosong
	if req.NamaObat != "" {
		existing.NamaObat = req.NamaObat
	}
	if req.KategoriIndikasi != "" {
		existing.KategoriIndikasi = req.KategoriIndikasi
	}
	if req.FrekuensiMin > 0 {
		existing.FrekuensiMin = req.FrekuensiMin
	}
	if req.FrekuensiMax > 0 {
		existing.FrekuensiMax = req.FrekuensiMax
	}
	if req.DurasiMin > 0 {
		existing.DurasiMin = req.DurasiMin
	}
	if req.DurasiMax > 0 {
		existing.DurasiMax = req.DurasiMax
	}
	if len(req.WaktuKonsumsi) > 0 {
		waktuJSON, _ := json.Marshal(req.WaktuKonsumsi)
		existing.WaktuKonsumsi = string(waktuJSON)
	}
	if req.Fungsi != "" {
		existing.Fungsi = req.Fungsi
	}
	if req.AturanPenggunaan != "" {
		existing.AturanPenggunaan = req.AturanPenggunaan
	}
	if req.Perhatian != "" {
		existing.Perhatian = req.Perhatian
	}
	if req.Gambar != "" {
		existing.Gambar = req.Gambar
	}

	// Save updates
	result, err := u.repo.Update(id, existing)
	if err != nil {
		return nil, errors.New("gagal memperbarui data obat")
	}

	return persistence.ObatToResponseDTO(result), nil
}

// Delete menghapus obat
func (u *ObatUsecase) Delete(id int) error {
	// Cek obat ada atau tidak
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil || existing.ObatID == 0 {
		return errors.New("obat tidak ditemukan")
	}

	// Delete from database
	return u.repo.Delete(id)
}
