import 'user_role.dart';

class AppUser {
  final String id;
  final UserRole role;
  final Map<String, dynamic>? pharmacyDetails;

  AppUser({required this.id, required this.role, this.pharmacyDetails});
}
