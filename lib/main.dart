import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_options.dart';
import 'features/dispatch/providers/dispatch_provider.dart';
import 'features/gps/providers/gps_provider.dart';
import 'features/voice_commands/providers/voice_command_provider.dart';
import 'features/photo_docs/providers/photo_doc_provider.dart';
import 'features/time_tracking/providers/time_tracking_provider.dart';
import 'features/accounting/providers/accounting_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/driver_panel/providers/driver_panel_provider.dart';
import 'features/crash_detection/providers/crash_detection_provider.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization — runs when configured, otherwise dev mode.
  if (FirebaseConfig.isConfigured) {
    // TODO: Uncomment once firebase_core is initialized with platform folders:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  } else {
    FirebaseConfig.printSetupInstructions();
  }

  runApp(const WreckerLogixApp());
}

class WreckerLogixApp extends StatelessWidget {
  const WreckerLogixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DispatchProvider()),
        ChangeNotifierProvider(create: (_) => GpsProvider()),
        ChangeNotifierProvider(create: (_) => VoiceCommandProvider()),
        ChangeNotifierProvider(create: (_) => PhotoDocProvider()),
        ChangeNotifierProvider(create: (_) => TimeTrackingProvider()),
        ChangeNotifierProvider(create: (_) => AccountingProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DriverPanelProvider()),
        ChangeNotifierProvider(create: (_) => CrashDetectionProvider()),
      ],
      child: MaterialApp.router(
        title: 'WreckerLogix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
