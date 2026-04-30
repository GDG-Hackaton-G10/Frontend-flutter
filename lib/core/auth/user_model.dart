import 'user_role.dart';

class UserModel {
  const UserModel({required this.id, required this.email, required this.role});

  final String id;
  final String email;
  final UserRole role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleValue = (json['role'] ?? 'user').toString().toLowerCase();

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: roleValue == 'pharmacy' ? UserRole.pharmacy : UserRole.patient,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role == UserRole.pharmacy ? 'pharmacy' : 'user',
    };
  }
}
