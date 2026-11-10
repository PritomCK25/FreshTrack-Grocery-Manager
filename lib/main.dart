
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabasePublishableKey,
  );

  runApp(const FreshTrackApp());
}

class FreshTrackApp extends StatelessWidget {
  const FreshTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check whether a user is already logged in.
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'FreshTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF167D48),
        ),
      ),

      // Open Dashboard if a session exists; otherwise open Login.
      home: session != null
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
