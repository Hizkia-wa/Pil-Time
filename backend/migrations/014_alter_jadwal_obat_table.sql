ALTER TABLE jadwal_obat
ADD COLUMN resep_obat_id INTEGER;
ADD COLUMN waktu_label VARCHAR(20);
ADD CONSTRAINT fk_jadwal_resep
FOREIGN KEY (resep_obat_id)
REFERENCES resep_obat(resep_obat_id)
ON DELETE CASCADE;