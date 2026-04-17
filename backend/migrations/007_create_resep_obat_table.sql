-- Create resep_obat (medication prescription) table
CREATE TABLE IF NOT EXISTS resep_obat (
    resep_obat_id SERIAL PRIMARY KEY,
    pasien_id INTEGER NOT NULL,
    obat_id INTEGER NOT NULL,
    nakes_id INTEGER NOT NULL,
    dosis VARCHAR(100),
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resep_obat_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE,
    CONSTRAINT fk_resep_obat_obat FOREIGN KEY (obat_id) REFERENCES obat(obat_id) ON DELETE CASCADE,
    CONSTRAINT fk_resep_obat_nakes FOREIGN KEY (nakes_id) REFERENCES nakes(nakes_id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX idx_resep_obat_pasien ON resep_obat(pasien_id);
CREATE INDEX idx_resep_obat_obat ON resep_obat(obat_id);
CREATE INDEX idx_resep_obat_nakes ON resep_obat(nakes_id);
CREATE INDEX idx_resep_obat_tanggal_mulai ON resep_obat(tanggal_mulai);
