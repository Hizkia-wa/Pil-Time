package main

import (
	"backend/config"
	"backend/internal/domain"
	"backend/internal/usecase"
	"fmt"
	"log"
	"time"
)

func main() {
	log.Println("=== PIL-TIME WORKER VERIFICATION SYSTEM ===")
	db := config.InitPostgres()

	// 1. Dapatkan lokasi timezone WIB
	loc, err := time.LoadLocation("Asia/Jakarta")
	if err != nil {
		log.Fatalf("Gagal memuat timezone Asia/Jakarta: %v", err)
	}

	// 2. Bersihkan mock lama jika ada agar tes bersifat repeatable
	db.Exec("DELETE FROM wa_warnings WHERE jadwal_id IN (SELECT jadwal_id FROM jadwal WHERE nama_obat = 'Mock Vit-C Test')")
	db.Exec("DELETE FROM tracking_jadwal WHERE jadwal_id IN (SELECT jadwal_id FROM jadwal WHERE nama_obat = 'Mock Vit-C Test')")
	db.Exec("DELETE FROM jadwal WHERE nama_obat = 'Mock Vit-C Test'")
	db.Exec("DELETE FROM pasien WHERE email = 'test_pendamping@sahabatsehat.com'")

	// 3. Buat mock Pasien dengan no_telepon_pendamping
	testPasien := &domain.Pasien{
		Nama:                "Pasien Uji Coba WA",
		Email:               "test_pendamping@sahabatsehat.com",
		Password:            "hashed_password_placeholder",
		NIK:                 "9999888877776666",
		NoTelepon:           "+62855512345",
		NoTeleponPendamping: "+628123456789", // Nomor WA pendamping untuk tes
	}
	if err := db.Create(testPasien).Error; err != nil {
		log.Fatalf("Gagal membuat mock pasien: %v", err)
	}
	log.Printf("Mock Pasien berhasil dibuat: ID %d, Nama: %s, WA Pendamping: %s\n", testPasien.PasienID, testPasien.Nama, testPasien.NoTeleponPendamping)

	// 4. Hitung waktu jadwal agar tepat 45 menit yang lalu dari sekarang
	nowInWib := time.Now().In(loc)
	scheduleTimeWib := nowInWib.Add(-45 * time.Minute)
	timeStr := scheduleTimeWib.Format("15:04")
	todayStr := nowInWib.Format("2006-01-02")

	log.Printf("Sekarang (WIB): %s. Menyetel jadwal minum obat tepat jam: %s (45 menit yang lalu)\n", nowInWib.Format("15:04:05"), timeStr)

	// 5. Buat mock Jadwal Obat aktif
	testJadwal := &domain.Jadwal{
		PasienID:         testPasien.PasienID,
		NamaObat:         "Mock Vit-C Test",
		JumlahDosis:      1,
		Satuan:           "Tablet",
		KategoriObat:     "Suplemen",
		TakaranObat:      "500mg",
		FrekuensiPerHari: "1x sehari",
		WaktuMinum:       timeStr,
		AturanKonsumsi:   "Sesudah Makan",
		TipeDurasi:       "rutin",
		TanggalMulai:     todayStr,
		Status:           "aktif",
	}
	if err := db.Create(testJadwal).Error; err != nil {
		log.Fatalf("Gagal membuat mock jadwal: %v", err)
	}
	log.Printf("Mock Jadwal berhasil dibuat: ID %d, Obat: %s, Jam: %s\n", testJadwal.JadwalID, testJadwal.NamaObat, testJadwal.WaktuMinum)

	// 6. Inisialisasi worker
	worker := usecase.NewWaWarningWorker(db)

	log.Println("\n--- MENJALANKAN DETEKSI WORKER (PANGGILAN PERTAMA) ---")
	log.Println("Ekspektasi: Peringatan WA terkirim dan tercatat ke DB.")
	worker.CheckAndSendWarnings()

	// Verifikasi apakah log warning tersimpan ke database
	var count int64
	db.Table("wa_warnings").Where("jadwal_id = ?", testJadwal.JadwalID).Count(&count)
	if count == 1 {
		fmt.Println("\033[1;32m✓ VERIFIKASI LOG DB SUKSES: 1 Log Peringatan berhasil tercatat!\033[0m")
	} else {
		fmt.Printf("\033[1;31m✗ VERIFIKASI LOG DB GAGAL: Ditemukan %d log (seharusnya 1)\033[0m\n", count)
	}

	log.Println("\n--- MENJALANKAN DETEKSI WORKER (PANGGILAN KEDUA) ---")
	log.Println("Ekspektasi: Tidak ada peringatan WA dikirim ulang (At-Most-Once).")
	worker.CheckAndSendWarnings()

	db.Table("wa_warnings").Where("jadwal_id = ?", testJadwal.JadwalID).Count(&count)
	if count == 1 {
		fmt.Println("\033[1;32m✓ VERIFIKASI DUPLIKASI SUKSES: Peringatan tidak dikirim ulang!\033[0m")
	} else {
		fmt.Printf("\033[1;31m✗ VERIFIKASI DUPLIKASI GAGAL: Log bertambah menjadi %d!\033[0m\n", count)
	}

	log.Println("\n=== SELESAI UJI COBA ===")
}
