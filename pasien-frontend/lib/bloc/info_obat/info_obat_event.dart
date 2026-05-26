import 'package:equatable/equatable.dart';

abstract class InfoObatEvent extends Equatable {
  const InfoObatEvent();

  @override
  List<Object?> get props => [];
}

class FetchInfoObat extends InfoObatEvent {
  final int pasienId;

  const FetchInfoObat({required this.pasienId});

  @override
  List<Object?> get props => [pasienId];
}
