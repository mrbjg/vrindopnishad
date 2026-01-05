import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  // For Android, we must pass the Web Client ID as serverClientId to get a valid ID Token for Supabase
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '373857631114-tfrl4mn3ivb37f4nrrhrdlk50306v2db.apps.googleusercontent.com',
  );

  Stream<User?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((data) => data.session?.user);

  User? get currentUser => _supabase.auth.currentUser;

  // Email & Password Sign Up
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Email & Password Sign In
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In...");
      if (kIsWeb) {
        // Web: Use OAuth flow
        await _supabase.auth.signInWithOAuth(OAuthProvider.google);
        return null; // Redirects on web, no response immediately
      } else {
        // Mobile: Native Google Sign In
        print("Mobile flow: Signing in with Google...");
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print("Google Sign In canceled by user.");
          return null;
        }

        print("Google account retrieved: ${googleUser.email}");
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        print(
          "Tokens retrieved. idToken: ${idToken != null}, accessToken: ${accessToken != null}",
        );

        if (accessToken == null) {
          throw 'No Access Token found.';
        }
        if (idToken == null) {
          throw 'No ID Token found.';
        }

        print("Signing in to Supabase with ID Token...");
        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        print("Supabase login successful: ${response.user?.email}");
        return response;
      }
    } catch (e) {
      print("Google Sign In Error: $e");
      rethrow;
    }
  }

  // Apple Sign In
  Future<AuthResponse?> signInWithApple() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(OAuthProvider.apple);
        return null;
      } else {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        return await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: credential.identityToken!,
          accessToken: credential.authorizationCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
