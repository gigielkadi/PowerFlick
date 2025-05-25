import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final supabaseUrl = 'https://svrsdxptcuimdjtsimif.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2cnNkeHB0Y3VpbWRqdHNpbWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NjEwODAsImV4cCI6MjA2MzQzNzA4MH0._DLROyQYtOggqizqcAc_7mWxOB1NT_4ZsRd2qRs62ak';

  try {
    // Test connection by querying the profiles table
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/profiles?select=*&limit=1'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Try to create a test profile
    final testProfile = {
      'id': '00000000-0000-0000-0000-000000000000',
      'email': 'test@example.com',
      'name': 'Test User',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final createResponse = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/profiles'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(testProfile),
    );

    print('\nCreate profile response status: ${createResponse.statusCode}');
    print('Create profile response body: ${createResponse.body}');

  } catch (e) {
    print('Error: $e');
  }
} 