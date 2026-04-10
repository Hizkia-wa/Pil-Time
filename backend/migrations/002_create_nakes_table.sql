-- Create nakes table
CREATE TABLE IF NOT EXISTS nakes (
    nakes_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis_ilmu VARCHAR(50),
    pin VARCHAR(10),
    gambar VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index untuk email
CREATE INDEX IF NOT EXISTS idx_nakes_email ON nakes(email);
CREATE INDEX IF NOT EXISTS idx_nakes_status ON nakes(status);
