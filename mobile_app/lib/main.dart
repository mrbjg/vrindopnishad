import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'core/auth_provider.dart';
import 'features/main_navigation_screen.dart';
import 'features/auth_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await sb.Supabase.initialize(
    url: 'https://tilimltxgeucefxzerqi.supabase.co',
    anonKey: 'sb_publishable_0YiM-Q8itRORUDdToracaQ_vzcrjUlC',
  );

  // Initialize Notifications
  await NotificationService().init();

  runApp(const ProviderScope(child: SantVaaniApp()));
}

class SantVaaniApp extends ConsumerWidget {
  const SantVaaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Sant-Vaani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainNavigationScreen();
          }
          return const AuthScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        ),
        error: (err, stack) {
          // Clear stale session (e.g., refresh_token_already_used) and show login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sb.Supabase.instance.client.auth.signOut();
          });
          return const AuthScreen();
        },
      ),
    );
  }
}
