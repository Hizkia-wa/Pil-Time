-- Add reset code fields to pasien table for forgot password feature
ALTER TABLE pasien 
ADD COLUMN reset_code VARCHAR(6),
ADD COLUMN reset_code_expiry TIMESTAMP;

-- Create index for faster queries on reset code
CREATE INDEX idx_pasien_reset_code ON pasien(reset_code);
