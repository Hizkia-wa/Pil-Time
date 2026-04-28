-- Add additional fields to obat table
-- This migration adds kategori_indikasi, frekuensi, durasi, and waktu_konsumsi fields

ALTER TABLE obat ADD COLUMN IF NOT EXISTS kategori_indikasi VARCHAR(255);
ALTER TABLE obat ADD COLUMN IF NOT EXISTS frekuensi_min INTEGER DEFAULT 1;
ALTER TABLE obat ADD COLUMN IF NOT EXISTS frekuensi_max INTEGER DEFAULT 1;
ALTER TABLE obat ADD COLUMN IF NOT EXISTS durasi_min INTEGER DEFAULT 1;
ALTER TABLE obat ADD COLUMN IF NOT EXISTS durasi_max INTEGER DEFAULT 1;
ALTER TABLE obat ADD COLUMN IF NOT EXISTS waktu_konsumsi TEXT; -- JSON array stored as text

-- Update column names for consistency with frontend
ALTER TABLE obat RENAME COLUMN aturan_pemakaian TO aturan_penggunaan;
ALTER TABLE obat RENAME COLUMN pantangan TO perhatian;

-- Create index for kategori_indikasi for faster filtering
CREATE INDEX IF NOT EXISTS idx_obat_kategori_indikasi ON obat(kategori_indikasi);
