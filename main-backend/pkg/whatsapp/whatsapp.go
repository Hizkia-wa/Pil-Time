package whatsapp

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

func SendWarning(toPhone, patientName, medicineName, scheduledTime string) {
	timestamp := time.Now().Format("2006-01-02 15:04:05 MST")
	border := "=========================================================================="
	fmt.Println()
	fmt.Println(border)
	fmt.Printf("\033[1;32m[SISTEM OTOMATIS: PENGIRIMAN PERINGATAN WHATSAPP]\033[0m\n")
	fmt.Printf("Waktu Proses : %s\n", timestamp)
	fmt.Printf("Tujuan (Pendamping WA) : \033[1;36m%s\033[0m\n", toPhone)
	fmt.Printf("Nama Pasien            : \033[1m%s\033[0m\n", patientName)
	fmt.Printf("Nama Obat              : \033[1;33m%s\033[0m\n", medicineName)
	fmt.Printf("Jadwal Minum           : %s WIB\n", scheduledTime)
	fmt.Println("--------------------------------------------------------------------------")

	messageContent := fmt.Sprintf(
		"Halo Pendamping,\n\n"+
			"Peringatan! Pasien atas nama *%s* belum menandai jadwal minum obat "+
			"*%s* yang dijadwalkan pada pukul *%s WIB* hari ini.\n\n"+
			"Mohon ingatkan pasien untuk segera meminum obatnya sebelum batas waktu habis.\n\n"+
			"Terima kasih,\n"+
			"Aplikasi Pil-Time",
		patientName, medicineName, scheduledTime,
	)

	fmt.Printf("Konten Pesan:\n\033[3m\"%s\"\033[0m\n", messageContent)
	fmt.Println(border)
	fmt.Println()

	// INTEGRASI GERBANG WA RIIL: FONNTE (DIKIRIM OTOMATIS OLEH SERVER BACKEND)
	fonnteToken := os.Getenv("FONNTE_TOKEN")
	if fonnteToken != "" {
		fmt.Printf("\033[1;33m[SYSTEM INTEGRATION] Mengirim pesan otomatis via Fonnte ke %s...\033[0m\n", toPhone)
		
		// Format nomor telepon ke standar internasional (62)
		cleanPhone := toPhone
		cleanPhone = strings.ReplaceAll(cleanPhone, " ", "")
		cleanPhone = strings.ReplaceAll(cleanPhone, "-", "")
		cleanPhone = strings.ReplaceAll(cleanPhone, "+", "")
		if strings.HasPrefix(cleanPhone, "0") {
			cleanPhone = "62" + cleanPhone[1:]
		}

		// Siapkan data Form URL Encoded
		form := url.Values{}
		form.Set("target", cleanPhone)
		form.Set("message", messageContent)
		form.Set("countryCode", "62")

		req, err := http.NewRequest("POST", "https://api.fonnte.com/send", strings.NewReader(form.Encode()))
		if err != nil {
			fmt.Printf("\033[1;31m[GATEWAY ERROR] Gagal membuat HTTP request: %v\033[0m\n", err)
			return
		}

		req.Header.Set("Authorization", fonnteToken)
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Do(req)
		if err != nil {
			fmt.Printf("\033[1;31m[GATEWAY ERROR] Gagal menghubungi server Fonnte: %v\033[0m\n", err)
			return
		}
		defer resp.Body.Close()

		// Baca body respon Fonnte untuk diagnostik
		buf := new(strings.Builder)
		_, _ = io.Copy(buf, resp.Body)
		respStr := buf.String()

		fmt.Printf("[GATEWAY DIAGNOSTIK] Respon Server Fonnte: %s\n", respStr)

		if resp.StatusCode == http.StatusOK {
			if strings.Contains(respStr, "\"status\":true") || strings.Contains(respStr, "true") {
				fmt.Printf("\033[1;32m[GATEWAY SUKSES] Sistem otomatis berhasil mengirimkan pesan WhatsApp asli ke nomor %s!\033[0m\n", toPhone)
			} else {
				fmt.Printf("\033[1;31m[GATEWAY FAILED] Gagal mengirim pesan. Periksa status/device Anda di Fonnte!\033[0m\n")
			}
		} else {
			fmt.Printf("\033[1;31m[GATEWAY ERROR] Server Fonnte menolak dengan status HTTP %d\033[0m\n", resp.StatusCode)
		}
	} else {
		fmt.Println("[SISTEM INFO] Untuk mengirim pesan WhatsApp asli secara otomatis ke pendamping, silakan daftarkan Token Fonnte gratis Anda di file .env dengan kunci: FONNTE_TOKEN=token_anda")
	}
}
