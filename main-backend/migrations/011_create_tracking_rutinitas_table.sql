-- Create tracking_rutinitas (routine activity compliance tracking) table
CREATE TABLE IF NOT EXISTS tracking_rutinitas (
    tracking_rutinitas_id SERIAL PRIMARY KEY,
    pasien_id INTEGER NOT NULL,
    tanggal DATE NOT NULL,
    status VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tracking_rutinitas_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX idx_tracking_rutinitas_pasien ON tracking_rutinitas(pasien_id);
CREATE INDEX idx_tracking_rutinitas_tanggal ON tracking_rutinitas(tanggal);
CREATE INDEX idx_tracking_rutinitas_status ON tracking_rutinitas(status);
