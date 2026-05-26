import 'package:equatable/equatable.dart';
import '../../models/dashboard.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Dashboard dashboard;
  final Map<String, List<String>> riwayatByDate;
  final Set<int> takenJadwalIds;
  final bool isMarking;

  const DashboardLoaded({
    required this.dashboard,
    required this.riwayatByDate,
    required this.takenJadwalIds,
    this.isMarking = false,
  });

  DashboardLoaded copyWith({
    Dashboard? dashboard,
    Map<String, List<String>>? riwayatByDate,
    Set<int>? takenJadwalIds,
    bool? isMarking,
  }) {
    return DashboardLoaded(
      dashboard: dashboard ?? this.dashboard,
      riwayatByDate: riwayatByDate ?? this.riwayatByDate,
      takenJadwalIds: takenJadwalIds ?? this.takenJadwalIds,
      isMarking: isMarking ?? this.isMarking,
    );
  }

  @override
  List<Object?> get props => [dashboard, riwayatByDate, takenJadwalIds, isMarking];
}

class DashboardFailure extends DashboardState {
  final String error;
  final int? statusCode;

  const DashboardFailure({required this.error, this.statusCode});

  @override
  List<Object?> get props => [error, statusCode];
}

class DashboardMarkingSuccess extends DashboardState {
  final String message;

  const DashboardMarkingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardMarkingFailure extends DashboardState {
  final String error;

  const DashboardMarkingFailure(this.error);

  @override
  List<Object?> get props => [error];
}
