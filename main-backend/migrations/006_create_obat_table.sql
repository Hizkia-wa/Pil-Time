-- Create obat (medication master data) table
CREATE TABLE IF NOT EXISTS obat (
    obat_id SERIAL PRIMARY KEY,
    nama_obat VARCHAR(255) NOT NULL,
    fungsi TEXT,
    aturan_pemakaian TEXT,
    pantangan TEXT,
    gambar VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX idx_obat_nama_obat ON obat(nama_obat);
