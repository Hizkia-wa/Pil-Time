-- Create rutinitas (patient routine activities) table
CREATE TABLE IF NOT EXISTS rutinitas (
    rutinitas_id SERIAL PRIMARY KEY,
    pasien_id INTEGER NOT NULL,
    nama_rutinitas VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    waktu_reminder TIME,
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rutinitas_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX idx_rutinitas_pasien ON rutinitas(pasien_id);
CREATE INDEX idx_rutinitas_status ON rutinitas(status);
CREATE INDEX idx_rutinitas_tanggal_mulai ON rutinitas(tanggal_mulai);
