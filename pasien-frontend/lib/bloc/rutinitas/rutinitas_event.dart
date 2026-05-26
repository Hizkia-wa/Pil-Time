import 'package:equatable/equatable.dart';

abstract class RutinitasEvent extends Equatable {
  const RutinitasEvent();

  @override
  List<Object?> get props => [];
}

class FetchRutinitasSehat extends RutinitasEvent {
  final int pasienId;

  const FetchRutinitasSehat({required this.pasienId});

  @override
  List<Object?> get props => [pasienId];
}

class CreateObatMandiri extends RutinitasEvent {
  final Map<String, dynamic> data;

  const CreateObatMandiri(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateObatMandiri extends RutinitasEvent {
  final int obatId;
  final Map<String, dynamic> data;

  const UpdateObatMandiri({required this.obatId, required this.data});

  @override
  List<Object?> get props => [obatId, data];
}

class DeleteObatMandiri extends RutinitasEvent {
  final int obatId;

  const DeleteObatMandiri({required this.obatId});

  @override
  List<Object?> get props => [obatId];
}

class CreateRutinitasSehat extends RutinitasEvent {
  final Map<String, dynamic> payload;

  const CreateRutinitasSehat(this.payload);

  @override
  List<Object?> get props => [payload];
}

class UpdateRutinitasSehat extends RutinitasEvent {
  final int id;
  final Map<String, dynamic> payload;

  const UpdateRutinitasSehat({required this.id, required this.payload});

  @override
  List<Object?> get props => [id, payload];
}

class DeleteRutinitasSehat extends RutinitasEvent {
  final int id;

  const DeleteRutinitasSehat({required this.id});

  @override
  List<Object?> get props => [id];
}
