import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/constants/k_supabase.dart';
import 'lib/core/mcp/mcp_database.dart';

void main() async {
  print('Testing local Supabase connection...\n');

  // Test Supabase client connection
  try {
    await Supabase.initialize(
      url: KSupabase.url,
      anonKey: KSupabase.anonKey,
    );
    
    final supabase = Supabase.instance.client;
    
    // Test basic query
    final response = await supabase
        .from('information_schema.tables')
        .select('table_name')
        .eq('table_schema', 'public')
        .limit(1);
    
    print('✅ Supabase client connection successful!');
    print('Tables in database: $response\n');
  } catch (e) {
    print('❌ Supabase client connection failed: $e\n');
  }

  // Test direct PostgreSQL connection
  try {
    final db = McpDatabase();
    final connected = await db.connect();
    
    if (connected) {
      print('✅ PostgreSQL connection successful!');
      
      // Test creating tables
      await db.createTablesIfNeeded();
      print('✅ Database tables created/verified');
      
      // Test inserting a message
      await db.storeMessage({
        'type': 'test',
        'senderId': 'test_user',
        'content': {'message': 'Hello from test script!'},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Test message inserted');
      
      // Test retrieving messages
      final messages = await db.getMessages(limit: 1);
      print('✅ Retrieved messages: $messages');
      
      await db.disconnect();
    } else {
      print('❌ PostgreSQL connection failed');
    }
  } catch (e) {
    print('❌ PostgreSQL connection error: $e');
  }
} 