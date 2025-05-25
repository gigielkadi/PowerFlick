import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerflick/core/constants/k_supabase.dart';
import 'package:powerflick/core/mcp/mcp_database.dart';
import 'dart:math';

void main() {
  late SupabaseClient supabase;
  late McpDatabase mcpDatabase;

  setUpAll(() async {
    // Initialize Supabase client
    supabase = SupabaseClient(
      KSupabase.url,
      KSupabase.anonKey,
    );

    // Initialize MCP database
    mcpDatabase = McpDatabase();
  });

  test('Supabase sign up and sign in test', () async {
    // Generate a random email to avoid conflicts
    final random = Random();
    final email = 'testuser_${random.nextInt(1000000)}@example.com';
    final password = 'TestPassword123!';

    try {
      // Sign up
      final signUpResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      expect(signUpResponse.user, isNotNull, reason: 'Sign up failed');
      print('✅ Sign up successful for $email');

      // Sign out
      await supabase.auth.signOut();

      // Sign in
      final signInResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      expect(signInResponse.user, isNotNull, reason: 'Sign in failed');
      print('✅ Sign in successful for $email');
    } catch (e) {
      fail('Failed to sign up/sign in: $e');
    }
  });

  test('Supabase connection test', () async {
    try {
      // Test Supabase connection by fetching the current user
      final response = await supabase.auth.getUser();
      expect(response, isNotNull);
      print('Supabase connection successful!');
    } catch (e) {
      fail('Failed to connect to Supabase: $e');
    }
  });

  test('PostgreSQL connection test', () async {
    try {
      // Test PostgreSQL connection by creating a test table
      await mcpDatabase.execute('''
        CREATE TABLE IF NOT EXISTS test_connection (
          id SERIAL PRIMARY KEY,
          message TEXT NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Insert a test message
      await mcpDatabase.execute('''
        INSERT INTO test_connection (message)
        VALUES ('Test connection successful!')
      ''');

      // Query the test message
      final result = await mcpDatabase.query('''
        SELECT * FROM test_connection
        ORDER BY created_at DESC
        LIMIT 1
      ''');

      expect(result, isNotEmpty);
      expect(result[0]['message'], 'Test connection successful!');
      print('PostgreSQL connection successful!');

      // Clean up
      await mcpDatabase.execute('DROP TABLE IF EXISTS test_connection');
    } catch (e) {
      fail('Failed to connect to PostgreSQL: $e');
    }
  });
} 