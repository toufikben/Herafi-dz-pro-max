import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

/// مزود المستخدم الحالي
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref.read(authServiceProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      if (!_authService.isLoggedIn) {
        state = const AsyncValue.data(null);
        return;
      }
      final user = await _authService.getCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> setUser(UserModel user) async {
    state = AsyncValue.data(user);
  }

  Future<void> clear() async {
    state = const AsyncValue.data(null);
  }
}
