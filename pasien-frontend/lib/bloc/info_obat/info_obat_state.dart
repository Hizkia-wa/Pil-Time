import 'package:equatable/equatable.dart';
import '../../screens/info_obat/info_obat.dart';

abstract class InfoObatState extends Equatable {
  const InfoObatState();

  @override
  List<Object?> get props => [];
}

class InfoObatInitial extends InfoObatState {}

class InfoObatLoading extends InfoObatState {}

class InfoObatLoaded extends InfoObatState {
  final List<ObatDay> obatDays;

  const InfoObatLoaded(this.obatDays);

  @override
  List<Object?> get props => [obatDays];
}

class InfoObatFailure extends InfoObatState {
  final String error;

  const InfoObatFailure(this.error);

  @override
  List<Object?> get props => [error];
}
