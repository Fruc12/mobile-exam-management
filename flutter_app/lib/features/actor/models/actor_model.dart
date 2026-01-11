import '../../auth/models/user_model.dart';

class ActorModel {
  final int id;
  final String npi;
  final String nRib;
  final String idCard;
  final String rib;
  final DateTime birthdate;
  final String birthplace;
  final String diploma;
  final String bank;
  final String? phone;
  final int userId;
  final UserModel? user;

  ActorModel({
    required this.id,
    required this.npi,
    required this.nRib,
    required this.idCard,
    required this.rib,
    required this.birthdate,
    required this.birthplace,
    required this.diploma,
    required this.bank,
    this.phone,
    required this.userId,
    this.user,
  });

  factory ActorModel.fromJson(Map<String, dynamic> json) {
    return ActorModel(
      id: json['id'],
      npi: json['npi'],
      nRib: json['n_rib'],
      idCard: json['id_card'],
      rib: json['rib'],
      birthdate: DateTime.parse(json['birthdate']),
      birthplace: json['birthplace'],
      diploma: json['diploma'],
      bank: json['bank'],
      phone: json['phone'],
      userId: json['user_id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'npi': npi,
      'n_rib': nRib,
      'id_card': idCard,
      'rib': rib,
      'birthdate': birthdate.toIso8601String(),
      'birthplace': birthplace,
      'diploma': diploma,
      'bank': bank,
      'phone': phone,
      'user_id': userId,
    };
  }
}
