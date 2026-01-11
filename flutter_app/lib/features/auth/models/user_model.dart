import '../../actor/models/actor_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final ActorModel? actor;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.actor,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      actor: json['actor'] != null ? ActorModel.fromJson(json['actor']) : null,
    );
  }
}
