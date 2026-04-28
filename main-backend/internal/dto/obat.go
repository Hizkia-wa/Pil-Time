package dto

type CreateObatReq struct {
	NamaObat        string `json:"nama_obat" binding:"required"`
	Fungsi          string `json:"fungsi"`
	AturanPemakaian string `json:"aturan_pemakaian"`
	Pantangan       string `json:"pantangan"`
	Gambar          string `json:"gambar"` // Base64 or URL
}

type CreateObatMandiriReq struct {
	NamaObat  string `json:"nama_obat" binding:"required"`
	Dosis     string `json:"dosis" binding:"required"`
	Gambar    string `json:"gambar"` // Base64 or URL
	Pengingat string `json:"pengingat" binding:"required"` // pagi, siang, sore, malam
	Frekuensi string `json:"frekuensi" binding:"required"` // 1x sehari, 2x sehari, dll
	DurasiHari int   `json:"durasi_hari" binding:"required"`
	Catatan   string `json:"catatan"`
	PasienID  int    `json:"pasien_id" binding:"required"`
}

type ObatRes struct {
	ObatID          int     `json:"obat_id"`
	NamaObat        string  `json:"nama_obat"`
	Fungsi          string  `json:"fungsi"`
	AturanPemakaian string  `json:"aturan_pemakaian"`
	Pantangan       string  `json:"pantangan"`
	Gambar          string  `json:"gambar"`
	PasienID        *int    `json:"pasien_id"`
	Pengingat       string  `json:"pengingat"`
	Frekuensi       string  `json:"frekuensi"`
	DurasiHari      *int    `json:"durasi_hari"`
	Catatan         string  `json:"catatan"`
	IsMandiri       bool    `json:"is_mandiri"`
	CreatedAt       string  `json:"created_at"`
	UpdatedAt       string  `json:"updated_at"`
}
