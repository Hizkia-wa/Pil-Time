package domain

import "time"

type JadwalObat struct {
    JadwalObatID int `gorm:"primaryKey"` // 🔥 WAJIB

    ResepObatID  int
    ObatID       int
    NakesID      int
    JamMinum     time.Time
    CreatedAt    time.Time
    UpdatedAt    time.Time
}