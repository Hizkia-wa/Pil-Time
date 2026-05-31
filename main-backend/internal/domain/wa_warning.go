package domain

import "time"

type WaWarning struct {
	ID       uint      `gorm:"primaryKey;column:id"`
	JadwalID int       `gorm:"column:jadwal_id;not null;index"`
	Tanggal  time.Time `gorm:"column:tanggal;type:date;not null;index"`
	SentAt   time.Time `gorm:"column:sent_at;autoCreateTime"`
}

func (WaWarning) TableName() string {
	return "wa_warnings"
}
