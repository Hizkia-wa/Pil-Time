import 'package:equatable/equatable.dart';
import '../../models/jadwal.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboard extends DashboardEvent {
  final int pasienId;
  final String pasienNama;

  const FetchDashboard({required this.pasienId, required this.pasienNama});

  @override
  List<Object?> get props => [pasienId, pasienNama];
}

class MarkAsTaken extends DashboardEvent {
  final Jadwal jadwal;
  final int pasienId;

  const MarkAsTaken({required this.jadwal, required this.pasienId});

  @override
  List<Object?> get props => [jadwal, pasienId];
}

/// Event khusus untuk menandai satu slot waktu obat mandiri sebagai diminum
class MarkMandiriSlotAsTaken extends DashboardEvent {
  final Jadwal jadwal;
  final int pasienId;
  /// Waktu slot spesifik, misal "07:00" atau "13:00"
  final String waktuSlot;

  const MarkMandiriSlotAsTaken({
    required this.jadwal,
    required this.pasienId,
    required this.waktuSlot,
  });

  @override
  List<Object?> get props => [jadwal, pasienId, waktuSlot];
}
