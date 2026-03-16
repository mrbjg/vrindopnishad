import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/design_system.dart';
import 'core/providers.dart';
import 'core/auth_provider.dart';
import 'features/main_navigation_screen.dart';
import 'features/auth_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

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

  runApp(const ProviderScope(child: SantVaaniPremiumApp()));
}

class SantVaaniPremiumApp extends ConsumerWidget {
  const SantVaaniPremiumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force dark mode for premium spiritual aesthetic
    // final themeMode = ref.watch(themeProvider); 
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Sant-Vaani Premium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: PremiumTokens.charcoal,
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: PremiumTokens.charcoal,
      ),
      themeMode: ThemeMode.dark, // Defaulting to dark for premium feel
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sb.Supabase.instance.client.auth.signOut();
          });
          return const AuthScreen();
        },
      ),
    );
  }
}
