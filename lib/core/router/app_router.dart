import 'package:go_router/go_router.dart';
import '../../features/dispatch/screens/dispatch_screen.dart';
import '../../features/dispatch/screens/job_detail_screen.dart';
import '../../features/dispatch/screens/create_job_screen.dart';
import '../../features/gps/screens/gps_screen.dart';
import '../../features/voice_commands/screens/voice_command_screen.dart';
import '../../features/photo_docs/screens/photo_doc_screen.dart';
import '../../features/time_tracking/screens/time_tracking_screen.dart';
import '../../features/accounting/screens/accounting_screen.dart';
import '../../features/accounting/screens/create_invoice_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/driver_panel/screens/driver_panel_screen.dart';
import '../../features/maintenance/screens/maintenance_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';

/// Centralized routing using GoRouter.
class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dispatch',
        builder: (context, state) => const DispatchScreen(),
      ),
      GoRoute(
        path: '/dispatch/create',
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: '/dispatch/:jobId',
        builder: (context, state) => JobDetailScreen(
          jobId: state.pathParameters['jobId']!,
        ),
      ),
      GoRoute(
        path: '/gps',
        builder: (context, state) => const GpsScreen(),
      ),
      GoRoute(
        path: '/voice',
        builder: (context, state) => const VoiceCommandScreen(),
      ),
      GoRoute(
        path: '/photos',
        builder: (context, state) => const PhotoDocScreen(),
      ),
      GoRoute(
        path: '/time-tracking',
        builder: (context, state) => const TimeTrackingScreen(),
      ),
      GoRoute(
        path: '/accounting',
        builder: (context, state) => const AccountingScreen(),
      ),
      GoRoute(
        path: '/accounting/create-invoice',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/driver-panel',
        builder: (context, state) => const DriverPanelScreen(),
      ),
      GoRoute(
        path: '/maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AiAssistantScreen(),
      ),
    ],
  );
}
