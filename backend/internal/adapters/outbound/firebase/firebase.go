package firebase

import (
	"context"
	"fmt"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
)

type firebaseService struct {
	client *messaging.Client
}

func NewFirebaseService() (*firebaseService, error) {
	ctx := context.Background()

	opt := option.WithCredentialsFile("firebase-service-account.json")

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, err
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, err
	}

	return &firebaseService{client}, nil
}

func (f *firebaseService) SendNotification(token string, title string, body string) error {
	ctx := context.Background()

	msg := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
	}

	res, err := f.client.Send(ctx, msg)
	if err != nil {
		return err
	}

	fmt.Println("Notification sent:", res)
	return nil
}