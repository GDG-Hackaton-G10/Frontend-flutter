import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier with AsyncNotifier<AppUser?> {
  late final AuthRepository _repo;

  @override
  FutureOr<AppUser?> build() async {
    _repo = AuthRepositoryImpl();
    final user = await _repo.getCurrentUser();
    return user ?? AppUser(id: '', role: UserRole.guest);
  }

  Future<void> signIn(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repo.signIn(username, password);
      final user = await _repo.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = AsyncValue.data(AppUser(id: '', role: UserRole.guest));
  }
}
