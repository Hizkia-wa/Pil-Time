-- Create jadwal_obat (medication schedule) table
CREATE TABLE IF NOT EXISTS jadwal_obat (
    jadwal_obat_id SERIAL PRIMARY KEY,
    obat_id INTEGER NOT NULL,
    tracking_obat_id INTEGER,
    nakes_id INTEGER NOT NULL,
    jam_minum TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_jadwal_obat_obat FOREIGN KEY (obat_id) REFERENCES obat(obat_id) ON DELETE CASCADE,
    CONSTRAINT fk_jadwal_obat_nakes FOREIGN KEY (nakes_id) REFERENCES nakes(nakes_id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX idx_jadwal_obat_obat ON jadwal_obat(obat_id);
CREATE INDEX idx_jadwal_obat_nakes ON jadwal_obat(nakes_id);
