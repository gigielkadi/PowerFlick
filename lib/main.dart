import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/k_supabase.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/navigation_observer.dart';
import 'powerflick/auth/presentation/pages/login_page.dart';
import 'powerflick/auth/presentation/pages/signup_page.dart';
import 'powerflick/auth/presentation/pages/welcome_page.dart';
import 'powerflick/auth/presentation/pages/subscription_plan_page.dart';
import 'powerflick/auth/presentation/pages/user_profile_form_page.dart';
import 'powerflick/dashboard/presentation/pages/dashboard_page.dart';
import 'powerflick/admin/presentation/pages/supabase_admin_page.dart';
import 'powerflick/admin/presentation/pages/admin_launcher.dart';
import 'powerflick/mcp/presentation/pages/mcp_page.dart';
import 'powerflick/home/presentation/pages/home_page.dart';
import 'powerflick/home/presentation/pages/rooms_list_page.dart';
import 'powerflick/auth/presentation/pages/choose_devices_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: KSupabase.url,
    anonKey: KSupabase.anonKey,
  );
  
  runApp(
    const ProviderScope(
      child: PowerFlickApp(),
    ),
  );
}

class PowerFlickApp extends StatelessWidget {
  const PowerFlickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerFlick',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
      navigatorObservers: [NavigationLogger()],
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/subscription': (context) => const SubscriptionPlanPage(),
        '/profile-form': (context) => const UserProfileFormPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/supabase-admin': (context) => const SupabaseAdminPage(),
        '/admin': (context) => const AdminLauncher(),
        '/mcp': (context) => const McpPage(),
        '/home': (context) => const HomePage(),
        '/rooms': (context) => const RoomsListPage(),
        '/add-device': (context) => const ChooseDevicesPage(),
      },
    );
  }
}

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  _SupabaseTestPageState createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  late final SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
  }

  Future<List<String>> _fetchTables() async {
    try {
      final response = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => item['table_name'].toString()).toList();
    } catch (e) {
      print('Error fetching tables: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTableStructure(String tableName) async {
    try {
      final response = await supabase
          .from('information_schema.columns')
          .select()
          .eq('table_schema', 'public')
          .eq('table_name', tableName);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching table structure: $e');
      return [];
    }
  }

  void _testSupabaseConnection(BuildContext context) async {
    try {
      final response = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public')
          .limit(1);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Test'),
            content: Text('Successfully connected to Supabase at ${KSupabase.url}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Error'),
            content: Text('Failed to connect to Supabase: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerFlick'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'PowerFlick Connected to Supabase',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testSupabaseConnection(context),
              child: const Text('Test Supabase Connection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final tables = await _fetchTables();
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Database Tables'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...tables.map((table) => FutureBuilder<List<Map<String, dynamic>>>(
                              future: _fetchTableStructure(table),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final data = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\nTable: $table',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    ...data.map((col) => Text(
                                      '  - ${col['column_name']} (${col['data_type']}) ${col['is_nullable'] == 'YES' ? '(nullable)' : '(not null)'}',
                                    )),
                                  ],
                                );
                              },
                            )),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('View Database Structure'),
            ),
          ],
        ),
      ),
    );
  }
}
