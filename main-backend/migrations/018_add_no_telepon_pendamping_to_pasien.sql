-- Alter table pasien to add no_telepon_pendamping
ALTER TABLE pasien ADD COLUMN IF NOT EXISTS no_telepon_pendamping VARCHAR(100);
