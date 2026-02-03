import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_app/core/database/app_database.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncData(null));

  Future<void> registerProject({
    required String projectName,
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await AppDatabase.instance
          .registerProject(projectName, username, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await AppDatabase.instance.login(username, password);
      state = const AsyncData(null);
      return result != null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});
