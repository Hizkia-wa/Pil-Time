package usecase

import "backend/internal/ports/outbound"

type NotifUsecase struct {
	notif outbound.NotificationService
}

func NewNotifUsecase(n outbound.NotificationService) *NotifUsecase {
	return &NotifUsecase{n}
}

func (u *NotifUsecase) SendReminder(token string) error {
	return u.notif.SendNotification(
		token,
		"Reminder Obat 💊",
		"Jangan lupa minum obat ya!",
	)
}