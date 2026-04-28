-- Create tracking_obat (medication compliance tracking) table
CREATE TABLE IF NOT EXISTS tracking_obat (
    tracking_obat_id SERIAL PRIMARY KEY,
    pasien_id INTEGER NOT NULL,
    nakes_id INTEGER NOT NULL,
    tanggal DATE NOT NULL,
    status VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tracking_obat_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE,
    CONSTRAINT fk_tracking_obat_nakes FOREIGN KEY (nakes_id) REFERENCES nakes(nakes_id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX idx_tracking_obat_pasien ON tracking_obat(pasien_id);
CREATE INDEX idx_tracking_obat_nakes ON tracking_obat(nakes_id);
CREATE INDEX idx_tracking_obat_tanggal ON tracking_obat(tanggal);
CREATE INDEX idx_tracking_obat_status ON tracking_obat(status);
