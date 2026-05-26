import 'package:equatable/equatable.dart';
import '../../screens/notifikasi/notifikasi_screen.dart';

abstract class NotifikasiEvent extends Equatable {
  const NotifikasiEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotifikasiEvent {
  final int pasienId;

  const FetchNotifications({required this.pasienId});

  @override
  List<Object?> get props => [pasienId];
}

class MarkNotificationAsTaken extends NotifikasiEvent {
  final NotificationItem item;
  final int pasienId;

  const MarkNotificationAsTaken({required this.item, required this.pasienId});

  @override
  List<Object?> get props => [item, pasienId];
}

class DeferNotificationEvent extends NotifikasiEvent {
  final NotificationItem item;

  const DeferNotificationEvent({required this.item});

  @override
  List<Object?> get props => [item];
}

class UndeferNotificationEvent extends NotifikasiEvent {
  final NotificationItem item;

  const UndeferNotificationEvent({required this.item});

  @override
  List<Object?> get props => [item];
}

class SubmitMissedReasonEvent extends NotifikasiEvent {
  final NotificationItem item;
  final String reason;
  final int pasienId;

  const SubmitMissedReasonEvent({
    required this.item,
    required this.reason,
    required this.pasienId,
  });

  @override
  List<Object?> get props => [item, reason, pasienId];
}
