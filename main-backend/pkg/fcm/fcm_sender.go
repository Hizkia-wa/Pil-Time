package fcm

import (
	"context"
	"fmt"
	"log"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
)

var messagingClient *messaging.Client

// Init menginisialisasi Firebase Admin SDK.
// Panggil sekali di main() sebelum server start.
// credentialsFile: path ke serviceAccountKey.json
func Init(credentialsFile string) error {
	opt := option.WithCredentialsFile(credentialsFile)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return fmt.Errorf("firebase init error: %w", err)
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		return fmt.Errorf("firebase messaging init error: %w", err)
	}

	messagingClient = client
	log.Println("[FCM] Firebase Admin SDK initialized ✓")
	return nil
}

// SendJadwalNotification mengirim FCM data message ke device pasien.
// Menggunakan data message (bukan notification message) agar Flutter
// background handler bisa menangkap dan menyimpan ke local storage.
func SendJadwalNotification(ctx context.Context, fcmToken string, payload map[string]string) error {
	if messagingClient == nil {
		return fmt.Errorf("FCM client belum diinisialisasi, panggil fcm.Init() terlebih dahulu")
	}
	if fcmToken == "" {
		return nil // pasien belum register token — skip silently
	}

	message := &messaging.Message{
		Token: fcmToken,
		// Data message: tidak auto-display, dihandle Flutter background handler
		Data: payload,
		Android: &messaging.AndroidConfig{
			Priority: "high",
		},
	}

	_, err := messagingClient.Send(ctx, message)
	if err != nil {
		return fmt.Errorf("FCM send error: %w", err)
	}

	log.Printf("[FCM] Notification sent to token: %s...\n", fcmToken[:min(10, len(fcmToken))])
	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
