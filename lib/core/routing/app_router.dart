import 'package:flutter/material.dart';

import '../../powerflick/auth/presentation/pages/login_page.dart';
import '../../powerflick/auth/presentation/pages/welcome_page.dart';
import '../../powerflick/auth/presentation/pages/signup_page.dart';
import '../../powerflick/auth/presentation/pages/verification_waiting_page.dart';
import '../../powerflick/auth/presentation/pages/add_device_page.dart';
import '../../powerflick/auth/presentation/pages/scan_devices_page.dart';
import '../../powerflick/auth/presentation/pages/connect_smart_plugs_page.dart';
import '../../powerflick/dashboard/presentation/pages/control_panel_page.dart';
import '../../powerflick/dashboard/presentation/pages/dashboard_page.dart';
import '../../powerflick/admin/presentation/pages/supabase_admin_page.dart';
import '../../powerflick/admin/presentation/pages/admin_launcher.dart';
import '../../powerflick/mcp/presentation/pages/mcp_page.dart';
import '../../powerflick/home/presentation/pages/home_page.dart';
import '../../powerflick/home/presentation/pages/rooms_list_page.dart';
import '../../powerflick/auth/presentation/pages/subscription_plan_page.dart';
import '../../powerflick/settings/presentation/pages/settings_page.dart';

/// Router configuration for the app
class AppRouter {
  /// Returns the route settings for the given route name
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/welcome':
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case '/signup':
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
          settings: settings,
        );
      case '/verification-waiting':
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args != null && args['email'] != null ? args['email'] as String : '';
        return MaterialPageRoute(
          builder: (_) => VerificationWaitingPage(email: email),
          settings: settings,
        );
      case '/add-device':
        return MaterialPageRoute(
          builder: (_) => const AddDevicePage(),
          settings: settings,
        );
      case '/scan-devices':
        return MaterialPageRoute(
          builder: (_) => const ScanDevicesPage(),
          settings: settings,
        );
      case '/connect-smart-plugs':
        return MaterialPageRoute(
          builder: (_) => const ConnectSmartPlugsPage(),
          settings: settings,
        );
      case '/control-panel':
        return MaterialPageRoute(
          builder: (_) => const ControlPanelPage(),
          settings: settings,
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
      case '/supabase-admin':
        return MaterialPageRoute(
          builder: (_) => const SupabaseAdminPage(),
          settings: settings,
        );
      case '/admin':
        return MaterialPageRoute(
          builder: (_) => const AdminLauncher(),
          settings: settings,
        );
      case '/mcp':
        return MaterialPageRoute(
          builder: (_) => const McpPage(),
          settings: settings,
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case '/rooms':
        return MaterialPageRoute(
          builder: (_) => const RoomsListPage(),
          settings: settings,
        );
      case '/subscription-plan':
        return MaterialPageRoute(
          builder: (_) => const SubscriptionPlanPage(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }
} 