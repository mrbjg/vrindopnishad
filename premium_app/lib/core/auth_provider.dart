import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  // For Android, we must pass the Web Client ID as serverClientId to get a valid ID Token for Supabase
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '373857631114-tfrl4mn3ivb37f4nrrhrdlk50306v2db.apps.googleusercontent.com',
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In...");
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
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

        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );

        print("Signing in to Firebase with Credential...");
        final userCredential = await _auth.signInWithCredential(credential);
        print("Firebase login successful: ${userCredential.user?.email}");
        return userCredential;
      }
    } catch (e) {
      print("Google Sign In Error: $e");
      rethrow;
    }
  }

  // Apple Sign In
  Future<UserCredential?> signInWithApple() async {
    try {
      if (kIsWeb) {
        AppleAuthProvider appleProvider = AppleAuthProvider();
        return await _auth.signInWithPopup(appleProvider);
      } else {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oAuthCredential = OAuthProvider('apple.com').credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );

        return await _auth.signInWithCredential(oAuthCredential);
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
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
