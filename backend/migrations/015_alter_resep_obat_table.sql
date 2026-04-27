ALTER TABLE resep_obat
ADD COLUMN frekuensi_per_hari VARCHAR(20),
ADD COLUMN aturan_konsumsi VARCHAR(50),
ADD COLUMN tipe_durasi VARCHAR(20),
ADD COLUMN jumlah_hari INTEGER,
ADD COLUMN pengingat BOOLEAN DEFAULT false;