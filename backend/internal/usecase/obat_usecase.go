package usecase

import (
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"errors"
)

type ObatUsecase struct {
	repo outbound.ObatRepository
}

func NewObatUsecase(r outbound.ObatRepository) *ObatUsecase {
	return &ObatUsecase{repo: r}
}

// GetAll mendapatkan semua obat sesuai kolom DB
func (u *ObatUsecase) GetAll() ([]dto.ObatResponseDTO, error) {
	obats, err := u.repo.GetAll()
	if err != nil {
		return nil, err
	}

	responses := []dto.ObatResponseDTO{}
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

// Create membuat obat baru (Hanya menggunakan kolom yang ada di DB)
func (u *ObatUsecase) Create(req *dto.CreateObatDTO) (*dto.ObatResponseDTO, error) {
	// 1. Validasi Input Dasar
	if req.NamaObat == "" {
		return nil, errors.New("nama obat tidak boleh kosong")
	}

	// 2. Cek Duplikasi Nama
	existing, _ := u.repo.GetByName(req.NamaObat)
	if existing != nil && existing.ObatID != 0 {
		return nil, errors.New("obat dengan nama tersebut sudah ada")
	}

	// 3. Mapping DTO ke Domain (Hanya kolom SQL: nama, fungsi, aturan_pemakaian, pantangan, gambar)
	obat := &domain.Obat{
		NamaObat:        req.NamaObat,
		Fungsi:          req.Fungsi,
		AturanPemakaian: req.AturanPemakaian, // Sesuai kolom DB
		Pantangan:       req.Pantangan,       // Sesuai kolom DB
		Gambar:          req.Gambar,          // Path dari handler
	}

	// 4. Simpan ke Persistence
	result, err := u.repo.Create(obat)
	if err != nil {
		return nil, errors.New("gagal menyimpan data obat ke database")
	}

	return persistence.ObatToResponseDTO(result), nil
}

// Update memperbarui data obat (Sesuai kolom DB)
func (u *ObatUsecase) Update(id int, req *dto.UpdateObatDTO) (*dto.ObatResponseDTO, error) {
	// 1. Cari data lama
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil || existing.ObatID == 0 {
		return nil, errors.New("obat tidak ditemukan")
	}

	// 2. Partial Update (Hanya kolom yang ada di SQL)
	if req.NamaObat != "" {
		existing.NamaObat = req.NamaObat
	}
	if req.Fungsi != "" {
		existing.Fungsi = req.Fungsi
	}
	if req.AturanPemakaian != "" {
		existing.AturanPemakaian = req.AturanPemakaian
	}
	if req.Pantangan != "" {
		existing.Pantangan = req.Pantangan
	}

	// 3. Logika Gambar: Tetap dipertahankan
	if req.Gambar != "" {
		existing.Gambar = req.Gambar
	}

	// 4. Eksekusi Update di Repo
	result, err := u.repo.Update(id, existing)
	if err != nil {
		return nil, errors.New("gagal memperbarui data obat")
	}

	return persistence.ObatToResponseDTO(result), nil
}

// Delete menghapus obat
func (u *ObatUsecase) Delete(id int) error {
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil || existing.ObatID == 0 {
		return errors.New("obat tidak ditemukan")
	}

	return u.repo.Delete(id)
}

// CreateMandiri membuat obat mandiri untuk pasien
func (u *ObatUsecase) CreateMandiri(req *dto.CreateObatMandiriDTO) (*dto.ObatResponseDTO, error) {
	// 1. Validasi Input
	if req.NamaObat == "" {
		return nil, errors.New("nama obat tidak boleh kosong")
	}
	if req.Dosis == "" {
		return nil, errors.New("dosis tidak boleh kosong")
	}
	if len(req.Pengingat) == 0 {
		return nil, errors.New("pengingat tidak boleh kosong")
	}
	if req.Frekuensi == "" {
		return nil, errors.New("frekuensi tidak boleh kosong")
	}
	if req.DurasiHari <= 0 {
		return nil, errors.New("durasi hari harus lebih dari 0")
	}
	if req.PasienID <= 0 {
		return nil, errors.New("pasien_id tidak valid")
	}

	// 2. Mapping DTO ke Domain
	obat := &domain.Obat{
		NamaObat:   req.NamaObat,
		Gambar:     req.Gambar,
		PasienID:   &req.PasienID,
		Frekuensi:  req.Frekuensi,
		DurasiHari: &req.DurasiHari,
		Catatan:    req.Catatan,
		IsMandiri:  true,
	}

	// Set pengingat sebagai JSON array
	if err := obat.SetPengingat(req.Pengingat); err != nil {
		return nil, errors.New("gagal menyimpan waktu pengingat")
	}

	// Dosis diisi di field Fungsi untuk kompatibilitas
	obat.Fungsi = req.Dosis

	// 3. Simpan ke Database
	result, err := u.repo.Create(obat)
	if err != nil {
		return nil, errors.New("gagal menyimpan data obat mandiri: " + err.Error())
	}

	return persistence.ObatToResponseDTO(result), nil
}