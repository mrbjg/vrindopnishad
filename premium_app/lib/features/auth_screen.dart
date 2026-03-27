import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      // Seamlessly Login or Register
      await authService.loginOrRegister(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showFriendlyError(_getFriendlyErrorMessage(e.code));
    } catch (e) {
      if (mounted) _showFriendlyError("Something unexpected happened on the path.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please provide a valid email to enter the sanctuary.';
      case 'wrong-password':
        return 'The password does not resonate. Please try again.';
      case 'weak-password':
        return 'Your password should be stronger to protect your journey.';
      default:
        return 'The path is momentarily blocked. Please try again.';
    }
  }

  void _showFriendlyError(String errorMsg) {
    PremiumUI.showNotification(
      context, 
      errorMsg,
      icon: Iconsax.info_circle,
      color: Colors.redAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.bokehBackground()),
          Positioned.fill(child: PremiumUI.mandalaOverlay(opacity: 0.05)),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section with Glowing Aura
                    PremiumUI.logoAnimated(height: 100),

                    const SizedBox(height: 24),

                    // Title Section
                    Text(
                      "Sant-Vaani",
                      style: GoogleFonts.newsreader(
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "THE VOICE OF SAINTS",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Auth Card
                    PremiumUI.glassCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildPremiumTextField(
                              controller: _emailController,
                              hint: "Email Address",
                              icon: Iconsax.sms,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildPremiumTextField(
                              controller: _passwordController,
                              hint: "Password",
                              icon: Iconsax.lock,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                                  color: Colors.white38,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading 
                                ? const Center(child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue))
                                : PremiumUI.primaryButton(
                                    text: "SECURE ENTRY",
                                    onTap: _handleEmailAuth,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Center(
                      child: Text(
                        "Enter your details to continue your journey.",
                        style: TextStyle(color: Colors.white24, fontSize: 13),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Social hint
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white10)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR", style: TextStyle(color: Colors.white24, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.white10)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialCircle(
                          image: "https://www.gstatic.com/images/branding/product/2x/googleg_96dp.png", 
                          onTap: () async {
                            setState(() => _isLoading = true);
                            try {
                              await ref.read(authServiceProvider).signInWithGoogle();
                            } catch (e) {
                              _showFriendlyError(e.toString());
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        ),
                        const SizedBox(width: 24),
                        _buildSocialCircle(icon: Icons.apple, onTap: () {}),
                      ],
                    ),
                    
                    const SizedBox(height: 48),

                    // Guest Login Option
                    GestureDetector(
                      onTap: () async {
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(authServiceProvider).signInAnonymously();
                        } catch (e) {
                          _showFriendlyError(e.toString());
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.user, color: Colors.white38, size: 16),
                            const SizedBox(width: 12),
                            Text(
                              "CONTINUE AS GUEST",
                              style: PremiumTokens.sansStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: PremiumTokens.sansStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: PremiumTokens.nebulaBlue.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PremiumTokens.nebulaBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  Widget _buildSocialCircle({IconData? icon, String? image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: image != null 
            ? PremiumUI.networkImage(url: image, width: 24, height: 24)
            : Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
