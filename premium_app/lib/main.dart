import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme.dart';
import 'core/design_system.dart';
import 'core/color_theme_provider.dart';
import 'core/mood_theme_provider.dart';
import 'core/auth_provider.dart';
import 'core/providers.dart';
import 'core/dynamic_icon_service.dart';
import 'features/main_navigation_screen.dart';
import 'features/auth_screen.dart';
import 'features/onboarding_screen.dart';
import 'features/splash_screen.dart';
import 'core/cache_service.dart';
import 'services/notification_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Cache & Storage first (Fast & Synchronous-ish)
  final prefs = await SharedPreferences.getInstance();
  await CacheService.instance.init();

  // Initialize Services in parallel for "Instant" opening feel
  // We wait for Firebase as it's critical for Auth, but other services can start in parallel
  // 1. Initialize Firebase first as it's a dependency for other services
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // 2. Initialize other services in parallel
  await Future.wait([
    sb.Supabase.initialize(
      url: 'https://tilimltxgeucefxzerqi.supabase.co',
      anonKey: 'sb_publishable_0YiM-Q8itRORUDdToracaQ_vzcrjUlC',
    ),
    
    JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
    
    // Now safe to initialize notifications
    NotificationService().init(),
  ]);

  // Schedule daily Naam Jap reminders: 7 AM morning + 8 PM evening
  unawaited(NotificationService().scheduleJapReminders(
    morningHour: 7,
    eveningHour: 20,
  ));

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const SantVaaniPremiumApp(),
  ));
}

class SantVaaniPremiumApp extends ConsumerStatefulWidget {
  const SantVaaniPremiumApp({super.key});

  @override
  ConsumerState<SantVaaniPremiumApp> createState() => _SantVaaniPremiumAppState();
}

class _SantVaaniPremiumAppState extends ConsumerState<SantVaaniPremiumApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Initialize Dynamic Icon Service to listen for milestones and toggles
    ref.read(dynamicIconServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);
    final colorPalette = ref.watch(colorPaletteProvider);
    final trueDarkEnabled = ref.watch(trueDarkEnabledProvider);
    final moodPalette = ref.watch(moodPaletteProvider);

    // Determine effective brightness from mood palette
    final moodBrightness = moodPalette.brightness;
    final effectiveThemeMode = themeMode == ThemeMode.system
        ? (moodBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light)
        : themeMode;
    
    // Update global brightness for static tokens
    final brightness = effectiveThemeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
    PremiumTokens.brightness = brightness;
    PremiumTokens.trueDarkEnabled = trueDarkEnabled;

    final activeMood = ref.watch(moodThemeProvider);

    // Sync mood palette to PremiumTokens
    PremiumTokens.setMoodTheme(
      theme: activeMood,
      brightness: moodPalette.brightness,
      scaffold: moodPalette.scaffoldBg,
      surface: moodPalette.surfaceColor,
      card: moodPalette.cardColor,
      textPrimary: moodPalette.textPrimary,
      textSecondary: moodPalette.textSecondary,
      textMuted: moodPalette.textMuted,
      border: moodPalette.borderColor,
      gradient: moodPalette.backgroundGradient,
    );

    // Sync active color palette to PremiumTokens
    PremiumTokens.setColorTheme(
      accent: colorPalette.accent,
      accentLight: colorPalette.accentLight,
      accentDark: colorPalette.accentDark,
      glow: colorPalette.glow,
      gradientColors: colorPalette.gradient,
    );

    // Generate ThemeData from mood palette
    final moodTheme = AppTheme.fromMood(moodPalette);

    return MaterialApp(
      title: 'Sant-Vaani Premium',
      debugShowCheckedModeBanner: false,
      theme: moodTheme,
      darkTheme: moodTheme,
      themeMode: effectiveThemeMode,
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
      return const OnboardingScreen(key: ValueKey('onboarding'));
    }

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigationScreen(key: ValueKey('main_nav'));
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
