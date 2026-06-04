import 'package:equatable/equatable.dart';

abstract class RutinitasState extends Equatable {
  const RutinitasState();

  @override
  List<Object?> get props => [];
}

class RutinitasSehatInitial extends RutinitasState {}

class RutinitasSehatLoading extends RutinitasState {}

class RutinitasSehatLoaded extends RutinitasState {
  final List<dynamic> listObat;
  final List<dynamic> listRutinitas;
  final int streakRutinitas;
  final int streakObat;

  const RutinitasSehatLoaded({
    required this.listObat,
    required this.listRutinitas,
    required this.streakRutinitas,
    required this.streakObat,
  });

  @override
  List<Object?> get props => [listObat, listRutinitas, streakRutinitas, streakObat];
}

class RutinitasSehatFailure extends RutinitasState {
  final String error;

  const RutinitasSehatFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// State untuk membedakan aksi mutasi (Create, Update, Delete)
class RutinitasActionLoading extends RutinitasState {}

class RutinitasActionSuccess extends RutinitasState {
  final String message;

  const RutinitasActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RutinitasActionFailure extends RutinitasState {
  final String error;

  const RutinitasActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
