import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;

  // For Android, we must pass the Web Client ID as serverClientId to get a valid ID Token for Supabase
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '1019370299171-vdf08iskqktbvrcntf3s1iadvracoued.apps.googleusercontent.com',
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

  // Combined Login or Register
  Future<UserCredential> loginOrRegister(String email, String password) async {
    try {
      // Try to sign in first
      return await signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // user-not-found is legacy, invalid-credential is the new standard
        // But for "login or register", we check if we should create a new account.
        // NOTE: In production, you might want to verify if they meant to register.
        // If sign-in fails because user doesn't exist, we sign them up.
        try {
          return await signUpWithEmail(email, password);
        } catch (signUpError) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Native Google Sign In
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;


        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential;
      }
    } catch (e) {
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
