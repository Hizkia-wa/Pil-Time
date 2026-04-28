package outbound

type NotificationService interface {
	SendNotification(token string, title string, body string) error
}