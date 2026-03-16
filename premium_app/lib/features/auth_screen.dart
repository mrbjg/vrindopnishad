import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
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
      if (_isLogin) {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showFriendlyError(e.code);
    } catch (e) {
      if (mounted) _showFriendlyError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFriendlyError(String errorMsg) {
    // Basic error handling - can be expanded
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
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
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glowing Aura
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumTokens.saffronGlow.withValues(alpha: 0.5),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                            duration: 3.seconds,
                            curve: Curves.easeInOut,
                          ),
                          
                          // Om Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
                              border: Border.all(color: PremiumTokens.saffronGlow.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                'ॐ',
                                style: GoogleFonts.manrope(
                                  fontSize: 48,
                                  color: PremiumTokens.saffronGlow,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title Section
                    Text(
                      "Sant-Vaani",
                      style: GoogleFonts.manrope(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: PremiumTokens.saffronGlow,
                        letterSpacing: -1,
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
                                ? const Center(child: CircularProgressIndicator(color: PremiumTokens.saffronGlow))
                                : PremiumUI.primaryButton(
                                    text: _isLogin ? "SIGN IN" : "CREATE ACCOUNT",
                                    onTap: _handleEmailAuth,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Toggle Button
                    GestureDetector(
                      onTap: () => setState(() => _isLogin = !_isLogin),
                      child: RichText(
                        text: TextSpan(
                          style: PremiumTokens.sansStyle(color: Colors.white54, fontSize: 15),
                          children: [
                            TextSpan(text: _isLogin ? "New seeker? " : "Already walking the path? "),
                            TextSpan(
                              text: _isLogin ? "Join Now" : "Sign In",
                              style: const TextStyle(color: PremiumTokens.saffronGlow, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
                          image: "https://lh3.googleusercontent.com/a/ACg8ocJcR2weulAnryBO4-25MppWiQI6nUuLO3h8h504UVVkBQzucX5Z=s96-c", 
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
        fillColor: PremiumTokens.saffronGlow.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: PremiumTokens.saffronGlow.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PremiumTokens.saffronGlow, width: 1.5),
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
