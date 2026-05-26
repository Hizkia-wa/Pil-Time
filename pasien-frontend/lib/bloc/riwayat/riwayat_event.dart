import 'package:equatable/equatable.dart';

abstract class RiwayatEvent extends Equatable {
  const RiwayatEvent();

  @override
  List<Object?> get props => [];
}

class FetchRiwayat extends RiwayatEvent {
  final int pasienId;

  const FetchRiwayat({required this.pasienId});

  @override
  List<Object?> get props => [pasienId];
}
