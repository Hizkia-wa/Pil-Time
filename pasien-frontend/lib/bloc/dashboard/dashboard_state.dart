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
  /// Key: "${jadwalId}_${waktu}" — untuk tracking per-slot obat mandiri
  final Set<String> takenMandiriSlots;
  final Set<int> missedJadwalIds;
  final Set<String> missedMandiriSlots;
  final bool isMarking;
  /// true jika state ini berasal dari FetchDashboard (full reload),
  /// false jika dari MarkAsTaken/MarkMandiriSlotAsTaken
  final bool fromFetch;

  const DashboardLoaded({
    required this.dashboard,
    required this.riwayatByDate,
    required this.takenJadwalIds,
    this.takenMandiriSlots = const {},
    this.missedJadwalIds = const {},
    this.missedMandiriSlots = const {},
    this.isMarking = false,
    this.fromFetch = false,
  });

  DashboardLoaded copyWith({
    Dashboard? dashboard,
    Map<String, List<String>>? riwayatByDate,
    Set<int>? takenJadwalIds,
    Set<String>? takenMandiriSlots,
    Set<int>? missedJadwalIds,
    Set<String>? missedMandiriSlots,
    bool? isMarking,
    bool? fromFetch,
  }) {
    return DashboardLoaded(
      dashboard: dashboard ?? this.dashboard,
      riwayatByDate: riwayatByDate ?? this.riwayatByDate,
      takenJadwalIds: takenJadwalIds ?? this.takenJadwalIds,
      takenMandiriSlots: takenMandiriSlots ?? this.takenMandiriSlots,
      missedJadwalIds: missedJadwalIds ?? this.missedJadwalIds,
      missedMandiriSlots: missedMandiriSlots ?? this.missedMandiriSlots,
      isMarking: isMarking ?? this.isMarking,
      fromFetch: fromFetch ?? this.fromFetch,
    );
  }

  @override
  List<Object?> get props => [
        dashboard,
        riwayatByDate,
        takenJadwalIds,
        takenMandiriSlots,
        missedJadwalIds,
        missedMandiriSlots,
        isMarking,
        fromFetch,
      ];
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
