-- Create pasien table
CREATE TABLE IF NOT EXISTS pasien (
    pasien_id SERIAL PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255) NOT NULL,
    nik VARCHAR(16) UNIQUE,
    tanggal_lahir DATE,
    tempat_lahir VARCHAR(100),
    alamat TEXT,
    jenis_kelamin CHAR(1) CHECK (jenis_kelamin IN ('L', 'P')),
    no_telepon VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX idx_pasien_email ON pasien(email);
CREATE INDEX idx_pasien_nik ON pasien(nik);
