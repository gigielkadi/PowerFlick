import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';

enum AuthStatus {
  initial,
  loading,
  success,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? error;
  final User? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class LoginNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final SupabaseClient _supabase;

  LoginNotifier(this._supabase) : super(AsyncValue.data(const AuthState()));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.loading();
    print('Starting login process for email: $email');

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        state = AsyncValue.data(
          AuthState(
            status: AuthStatus.success,
            user: response.user,
          ),
        );
        print('Login completed successfully');
      } else {
        state = AsyncValue.data(
          const AuthState(
            status: AuthStatus.error,
            error: 'Invalid email or password',
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('Email not confirmed')) {
        state = AsyncValue.data(
          const AuthState(
            status: AuthStatus.error,
            error: 'Please confirm your email address before logging in. Check your inbox for the confirmation link.',
          ),
        );
      } else {
        state = AsyncValue.data(
          const AuthState(
            status: AuthStatus.error,
            error: 'Invalid email or password',
          ),
        );
      }
    }
  }
}

class SignupNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final SupabaseClient _supabase;

  SignupNotifier(this._supabase) : super(AsyncValue.data(const AuthState()));

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.loading();
    print('Starting signup process for email: $email'); // Debug log

    try {
      // First, try to create the profiles table if it doesn't exist
      try {
        await _supabase.rpc('create_profiles_table');
      } catch (e) {
        print('Creating profiles table: $e'); // This is expected if table exists
        
        // Create the table manually if the RPC doesn't exist
        try {
          await _supabase.from('profiles').select().limit(1);
        } catch (e) {
          if (e.toString().contains('relation "profiles" does not exist')) {
            await _supabase.from('profiles').insert({
              'id': 'temp',
              'email': 'temp@temp.com',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            }).select();
          }
        }
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      print('Signup response: ${response.user?.toJson()}'); // Debug log

      if (response.user != null) {
        // Create a profile for the user
        try {
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('Profile created successfully'); // Debug log
        } catch (e) {
          print('Error creating profile: $e'); // Debug log
          // Even if profile creation fails, we still want to consider signup successful
          // as the auth account was created
        }

        state = AsyncValue.data(
          AuthState(
            status: AuthStatus.success,
            user: response.user,
          ),
        );
        print('Signup completed successfully'); // Debug log
      } else {
        print('Signup failed: No user in response'); // Debug log
        state = AsyncValue.data(
          const AuthState(
            status: AuthStatus.error,
            error: 'Failed to sign up',
          ),
        );
      }
    } catch (e) {
      print('Signup error: $e'); // Debug log
      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<AuthState>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return LoginNotifier(supabase);
});

final signupNotifierProvider =
    StateNotifierProvider<SignupNotifier, AsyncValue<AuthState>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SignupNotifier(supabase);
}); 