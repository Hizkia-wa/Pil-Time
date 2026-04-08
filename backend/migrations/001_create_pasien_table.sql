-- Create pasien table
CREATE TABLE IF NOT EXISTS pasien (
    pasien_id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    nik VARCHAR(16) NOT NULL UNIQUE,
    tanggal_lahir DATE NOT NULL,
    telepon VARCHAR(20) NOT NULL,
    jenis_kelamin VARCHAR(20) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    reset_code VARCHAR(6) DEFAULT NULL,
    reset_code_expiry TIMESTAMP DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX idx_pasien_email ON pasien(email);
CREATE INDEX idx_pasien_nik ON pasien(nik);
CREATE INDEX idx_pasien_status ON pasien(status);
