import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/k_supabase.dart';

class AdminLauncher extends StatefulWidget {
  const AdminLauncher({super.key});

  @override
  State<AdminLauncher> createState() => _AdminLauncherState();
}

class _AdminLauncherState extends State<AdminLauncher> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = false;
  String connectionStatus = '';
  bool isConnectionOk = false;
  
  @override
  void initState() {
    super.initState();
    _checkConnection();
  }
  
  Future<void> _checkConnection() async {
    setState(() {
      isLoading = true;
      connectionStatus = 'Checking connection...';
    });
    
    try {
      final response = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public')
          .limit(1);
          
      setState(() {
        isLoading = false;
        connectionStatus = 'Connected to Supabase';
        isConnectionOk = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        connectionStatus = 'Connection error: $e';
        isConnectionOk = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkConnection,
            tooltip: 'Test connection',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status card
              Card(
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isConnectionOk ? Icons.check_circle : Icons.error,
                            color: isConnectionOk ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Supabase Connection',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(connectionStatus),
                      const SizedBox(height: 8),
                      Text('URL: ${KSupabase.url}'),
                    ],
                  ),
                ),
              ),
              
              // Admin tools section
              Text(
                'Database Tools',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Tools grid
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAdminTool(
                    'Supabase Admin',
                    Icons.storage,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/supabase-admin'),
                    'View and manage database tables',
                  ),
                  _buildAdminTool(
                    'User Management',
                    Icons.people,
                    Colors.orange,
                    () {
                      // Show not implemented dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Coming Soon'),
                          content: const Text('User management tools are under development.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    'Manage user accounts',
                  ),
                  _buildAdminTool(
                    'System Logs',
                    Icons.list_alt,
                    Colors.green,
                    () {
                      // Show not implemented dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Coming Soon'),
                          content: const Text('System logs are under development.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    'View system activity logs',
                  ),
                  _buildAdminTool(
                    'Settings',
                    Icons.settings,
                    Colors.purple,
                    () {
                      // Show not implemented dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Coming Soon'),
                          content: const Text('Settings management is under development.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    'Configure system settings',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // API Information
              Text(
                'API Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supabase Configuration',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        KSupabase.url,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Project API Keys (Tap to reveal)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('API Keys Security'),
                                  content: const Text(
                                    'Be careful when sharing API keys. The anon key is safe to use in client applications, but the service role key should never be exposed to clients.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildHiddenApiKey('Anon Key'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAdminTool(
    String title, 
    IconData icon, 
    Color color, 
    VoidCallback onTap,
    String description,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHiddenApiKey(String label) {
    return GestureDetector(
      onTap: () {
        // Show the API key in a dialog when tapped
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$label Details'),
            content: SelectableText(
              label == 'Anon Key' 
                ? KSupabase.anonKey
                : 'Not available',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text('$label: '),
            const Expanded(
              child: Text(
                '••••••••••••••••••••••••••••••••',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const Icon(Icons.visibility, size: 16),
          ],
        ),
      ),
    );
  }
} 