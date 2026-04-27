package outbound

import "backend/internal/domain"

type ResepJadwalRepository interface {
    // Berikan nama yang unik untuk masing-masing fungsi
    CreateResep(data *domain.ResepObat) error
    CreateJadwal(data *domain.JadwalObat) error
}