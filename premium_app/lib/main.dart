import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme.dart';
import 'core/design_system.dart';
import 'core/auth_provider.dart';
import 'core/providers.dart';
import 'features/main_navigation_screen.dart';
import 'features/auth_screen.dart';
import 'features/onboarding_screen.dart';
import 'features/splash_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_core/firebase_core.dart';
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

class SantVaaniPremiumApp extends ConsumerStatefulWidget {
  const SantVaaniPremiumApp({super.key});

  @override
  ConsumerState<SantVaaniPremiumApp> createState() => _SantVaaniPremiumAppState();
}

class _SantVaaniPremiumAppState extends ConsumerState<SantVaaniPremiumApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    // Force dark mode for premium spiritual aesthetic
    final authState = ref.watch(authStateProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

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
      home: _showSplash 
        ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _buildEntryPoint(ref, authState, hasSeenOnboarding),
          ),
    );
  }

  Widget _buildEntryPoint(WidgetRef ref, AsyncValue<User?> authState, bool hasSeenOnboarding) {
    if (!hasSeenOnboarding) {
      return OnboardingScreen(key: const ValueKey('onboarding'));
    }

    return authState.when(
      data: (user) {
        if (user != null) {
          return MainNavigationScreen(key: const ValueKey('main_nav'));
        }
        return const AuthScreen(key: ValueKey('auth'));
      },
      loading: () => const Scaffold(
        key: ValueKey('loading'),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
      error: (err, stack) => const AuthScreen(key: ValueKey('auth_error')),
    );
  }
}
