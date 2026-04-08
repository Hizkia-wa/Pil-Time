package domain

import "time"

type Pasien struct {
	ID            uint
	Nama          string
	Email         string
	Password      string
	Nik           string
	TanggalLahir  time.Time
	TempatLahir   string
	Alamat        string
	JenisKelamin  string
	NoTelepon     string
}