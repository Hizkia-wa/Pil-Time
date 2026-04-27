package dto

type CreateResepWithJadwalDTO struct {
    PasienID int    `json:"pasien_id"`
    ObatID   int    `json:"obat_id"`
    NakesID  int    `json:"nakes_id"`

    Dosis   string `json:"dosis"`
    Catatan string `json:"catatan"`

    // ✅ TAMBAHKAN INI
    TanggalMulai   string `json:"tanggal_mulai"`
    TanggalSelesai string `json:"tanggal_selesai"`

    FrekuensiPerHari int      `json:"frekuensi_per_hari"`
    AturanKonsumsi   string   `json:"aturan_konsumsi"`
    JamMinum         []string `json:"jam_minum"`
}