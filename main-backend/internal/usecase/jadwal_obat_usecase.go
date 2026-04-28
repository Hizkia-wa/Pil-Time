package usecase

import (
    "backend/internal/domain"
    "backend/internal/dto"
    "backend/internal/ports/outbound"
    "time"
)

type JadwalObatUsecase struct {
    repo outbound.JadwalObatRepository
}

func NewJadwalObatUsecase(repo outbound.JadwalObatRepository) *JadwalObatUsecase {
    return &JadwalObatUsecase{repo: repo}
}

func (u *JadwalObatUsecase) Create(req *dto.CreateJadwalObatDTO) error {

    parsedTime, err := time.Parse("15:04", req.JamMinum)
    if err != nil {
        return err
    }

    jadwal := &domain.JadwalObat{
        ObatID:   req.ObatID,
        NakesID:  req.NakesID,
        JamMinum: parsedTime, // ✅ sudah benar
    }

    return u.repo.Create(jadwal)
}