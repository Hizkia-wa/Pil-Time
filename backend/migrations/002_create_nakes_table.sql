-- ============================================
-- TABEL NAKES (Tenaga Kesehatan)
-- ============================================
CREATE TABLE IF NOT EXISTS nakes (
    nakes_id SERIAL PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    nik VARCHAR(16) UNIQUE,
    jenis_kelamin CHAR(1) CHECK (jenis_kelamin IN ('L', 'P')),
    alamat TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster queries
CREATE INDEX idx_nakes_email ON nakes(email);
CREATE INDEX idx_nakes_nik ON nakes(nik);
