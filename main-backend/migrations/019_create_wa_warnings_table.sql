CREATE TABLE IF NOT EXISTS wa_warnings (
    id SERIAL PRIMARY KEY,
    jadwal_id INTEGER NOT NULL,
    tanggal DATE NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wa_warnings_jadwal FOREIGN KEY (jadwal_id) REFERENCES jadwal(jadwal_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_wa_warnings_jadwal_tanggal ON wa_warnings(jadwal_id, tanggal);
