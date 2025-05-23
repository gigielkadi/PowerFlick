import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../login_state.dart';

/// Notifier for handling login state and operations
class LoginNotifier extends AsyncNotifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState();
  }

  /// Signs in a user with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = const AsyncValue.data(LoginState());

      // TODO: Navigate to dashboard
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 