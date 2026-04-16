-- Create obat (medication info) table
CREATE TABLE IF NOT EXISTS obat (
    obat_id SERIAL PRIMARY KEY,
    nama_obat VARCHAR(255) NOT NULL UNIQUE,
    fungsi TEXT NOT NULL,
    aturan_penggunaan TEXT NOT NULL,
    perhatian TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX idx_obat_nama_obat ON obat(nama_obat);
