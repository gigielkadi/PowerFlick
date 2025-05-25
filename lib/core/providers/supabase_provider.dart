import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// Provider for the Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the Supabase auth client
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseProvider).auth;
});

/// Provider for the Supabase storage client
final supabaseStorageProvider = Provider((ref) {
  return ref.watch(supabaseProvider).storage;
});

/// Provider for the Supabase database client
final supabaseDatabaseProvider = Provider((ref) {
  return ref.watch(supabaseProvider);
}); 