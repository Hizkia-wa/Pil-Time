import 'package:equatable/equatable.dart';
import '../../screens/riwayat/riwayat_konsumsi_obat.dart';

abstract class RiwayatState extends Equatable {
  const RiwayatState();

  @override
  List<Object?> get props => [];
}

class RiwayatInitial extends RiwayatState {}

class RiwayatLoading extends RiwayatState {}

class RiwayatLoaded extends RiwayatState {
  final List<DayLog> allData;

  const RiwayatLoaded({required this.allData});

  @override
  List<Object?> get props => [allData];
}

class RiwayatFailure extends RiwayatState {
  final String error;

  const RiwayatFailure(this.error);

  @override
  List<Object?> get props => [error];
}
