-- Create nakes table
CREATE TABLE IF NOT EXISTS nakes (
    nakes_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nama VARCHAR(255) NOT NULL,
    nik VARCHAR(16),
    jenis_kelamin VARCHAR(20),
    alamat VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index untuk email
CREATE INDEX IF NOT EXISTS idx_nakes_email ON nakes(email);
CREATE INDEX IF NOT EXISTS idx_nakes_jenis_kelamin ON nakes(jenis_kelamin);
