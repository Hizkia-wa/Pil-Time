import 'package:equatable/equatable.dart';
import '../../screens/notifikasi/notifikasi_screen.dart';

abstract class NotifikasiState extends Equatable {
  const NotifikasiState();

  @override
  List<Object?> get props => [];
}

class NotifikasiInitial extends NotifikasiState {}

class NotifikasiLoading extends NotifikasiState {}

class NotifikasiLoaded extends NotifikasiState {
  final List<NotificationItem> allNotifications;
  final Set<NotificationItem> deferredNotifications;

  const NotifikasiLoaded({
    required this.allNotifications,
    required this.deferredNotifications,
  });

  NotifikasiLoaded copyWith({
    List<NotificationItem>? allNotifications,
    Set<NotificationItem>? deferredNotifications,
  }) {
    return NotifikasiLoaded(
      allNotifications: allNotifications ?? this.allNotifications,
      deferredNotifications: deferredNotifications ?? this.deferredNotifications,
    );
  }

  @override
  List<Object?> get props => [allNotifications, deferredNotifications];
}

class NotifikasiFailure extends NotifikasiState {
  final String error;

  const NotifikasiFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// State untuk aksi pencatatan
class NotifikasiActionLoading extends NotifikasiState {}

class NotifikasiActionSuccess extends NotifikasiState {
  final String message;

  const NotifikasiActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotifikasiActionFailure extends NotifikasiState {
  final String error;

  const NotifikasiActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
