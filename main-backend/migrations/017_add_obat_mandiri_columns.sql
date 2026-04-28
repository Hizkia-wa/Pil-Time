-- Add columns to obat table to support obat_mandiri
ALTER TABLE obat 
ADD COLUMN IF NOT EXISTS pasien_id INT,
ADD COLUMN IF NOT EXISTS pengingat VARCHAR(50), -- pagi, siang, sore, malam
ADD COLUMN IF NOT EXISTS frekuensi VARCHAR(100), -- "1x sehari", "2x sehari", dll
ADD COLUMN IF NOT EXISTS durasi_hari INT, -- berapa hari
ADD COLUMN IF NOT EXISTS catatan TEXT,
ADD COLUMN IF NOT EXISTS is_mandiri BOOLEAN DEFAULT FALSE;

-- Add foreign key for pasien_id
ALTER TABLE obat 
ADD CONSTRAINT fk_obat_pasien FOREIGN KEY (pasien_id) REFERENCES pasien(pasien_id) ON DELETE CASCADE;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_obat_pasien_id ON obat(pasien_id);
CREATE INDEX IF NOT EXISTS idx_obat_is_mandiri ON obat(is_mandiri);
