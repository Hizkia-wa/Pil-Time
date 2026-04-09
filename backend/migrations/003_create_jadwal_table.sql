-- Create jadwal table
CREATE TABLE IF NOT EXISTS jadwal (
	jadwal_id SERIAL PRIMARY KEY,
	pasien_id INTEGER NOT NULL,
	nama_obat VARCHAR(255) NOT NULL,
	jumlah_dosis INTEGER NOT NULL,
	satuan VARCHAR(50) NOT NULL,
	kategori_obat VARCHAR(255) NOT NULL,
	takaran_obat VARCHAR(100) NOT NULL,
	frekuensi_per_hari INTEGER NOT NULL,
	waktu_minum VARCHAR(50) NOT NULL,
	aturan_konsumsi VARCHAR(100) NOT NULL,
	catatan TEXT,
	tipe_durasi VARCHAR(20) NOT NULL,
	jumlah_hari INTEGER,
	tanggal_mulai DATE,
	tanggal_selesai DATE,
	waktu_reminder_pagi TIME,
	waktu_reminder_malam TIME,
	status VARCHAR(20) NOT NULL DEFAULT 'aktif',
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_jadwal_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_jadwal_pasien_id ON jadwal(pasien_id);
CREATE INDEX IF NOT EXISTS idx_jadwal_status ON jadwal(status);
CREATE INDEX IF NOT EXISTS idx_jadwal_created_at ON jadwal(created_at);
