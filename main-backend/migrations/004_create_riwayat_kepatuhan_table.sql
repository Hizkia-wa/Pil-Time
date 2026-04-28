-- Sesuai dengan PDM: tracking_jadwal untuk mencatat compliance jadwal obat
CREATE TABLE IF NOT EXISTS tracking_jadwal (
  tracking_jadwal_id SERIAL PRIMARY KEY,
  jadwal_id INTEGER NOT NULL,
  pasien_id INTEGER NOT NULL,
  tanggal DATE NOT NULL,
  status VARCHAR(50) NOT NULL CHECK (status IN ('Diminum', 'Terlambat', 'Terlewat')),
  waktu_minum TIME,
  catatan TEXT,
  bukti_foto VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_tracking_jadwal_jadwal FOREIGN KEY (jadwal_id) REFERENCES jadwal(jadwal_id) ON DELETE CASCADE,
  CONSTRAINT fk_tracking_jadwal_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE,
  
  INDEX idx_tracking_jadwal_pasien (pasien_id),
  INDEX idx_tracking_jadwal_jadwal (jadwal_id),
  INDEX idx_tracking_jadwal_tanggal (tanggal),
  INDEX idx_tracking_jadwal_status (status)
);

-- Riwayat obat untuk tracking history lengkap obat pasien
CREATE TABLE IF NOT EXISTS riwayat_obat (
  riwayat_obat_id SERIAL PRIMARY KEY,
  pasien_id INTEGER NOT NULL,
  tanggal DATE NOT NULL,
  status VARCHAR(50) NOT NULL,
  catatan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_riwayat_obat_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE,
  
  INDEX idx_riwayat_obat_pasien (pasien_id),
  INDEX idx_riwayat_obat_tanggal (tanggal),
  INDEX idx_riwayat_obat_status (status)
);
