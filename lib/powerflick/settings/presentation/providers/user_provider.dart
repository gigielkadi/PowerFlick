import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    throw Exception('User not authenticated');
  }
  
  try {
    // Try to fetch from users table first
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    
    return response;
  } catch (e) {
    // If users table doesn't exist or user not found, return basic auth data
    return {
      'id': user.id,
      'email': user.email,
      'first_name': user.userMetadata?['first_name'] ?? 'User',
      'name': user.userMetadata?['name'] ?? user.userMetadata?['first_name'] ?? 'User',
    };
  }
}); 