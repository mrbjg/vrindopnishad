import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
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
    } catch (e) {
      if (mounted) {
        _showFriendlyError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        _showFriendlyError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithApple();
    } catch (e) {
      if (mounted) {
        _showFriendlyError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFriendlyError(String errorMsg) {
    String title = "Oops!";
    String message = "Something went wrong. Please try again.";
    IconData icon = LucideIcons.alertCircle;

    // Parse common Firebase Auth errors
    if (errorMsg.contains('invalid-credential') ||
        errorMsg.contains('user-not-found') ||
        errorMsg.contains('wrong-password')) {
      title = "Incorrect Details";
      message =
          "The email or password you entered is incorrect. Please check and try again.";
      icon = LucideIcons.userX;
    } else if (errorMsg.contains('email-already-in-use')) {
      title = "Account Exists";
      message = "This email is already registered. Please sign in instead.";
      icon = LucideIcons.userCheck;
    } else if (errorMsg.contains('invalid-email')) {
      title = "Invalid Email";
      message = "Please enter a valid email address.";
      icon = LucideIcons.mailWarning;
    } else if (errorMsg.contains('weak-password')) {
      title = "Weak Password";
      message = "Your password is too weak. Please use at least 6 characters.";
      icon = LucideIcons.shieldAlert;
    } else if (errorMsg.contains('network-request-failed')) {
      title = "No Internet";
      message = "Please check your internet connection and try again.";
      icon = LucideIcons.wifiOff;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF1A1A2E).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.isDark(context)
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.red, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.spectral(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: AppTheme.textSecondary(context),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Error detail: $errorMsg",
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PressableScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          "Okay, Got it",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  LucideIcons.flame,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 36),

              // Title
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: GoogleFonts.spectral(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin
                    ? "Sign in to continue your spiritual journey"
                    : "Begin your path to enlightenment",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textMuted(context),
                ),
              ),

              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    _buildTextField(
                      controller: _emailController,
                      hint: "Email Address",
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: LucideIcons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 20,
                          color: AppTheme.textMuted(context),
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit button
                    PressableScale(
                      onTap: _isLoading ? null : _handleEmailAuth,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? "Sign In" : "Create Account",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppTheme.textMuted(context).withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: GoogleFonts.outfit(
                        color: AppTheme.textMuted(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppTheme.textMuted(context).withOpacity(0.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: Icons.g_mobiledata,
                    color: Colors.red,
                    onTap: _handleGoogleSignIn,
                  ),
                  const SizedBox(width: 16),
                  _buildSocialButton(
                    icon: Icons.apple,
                    color: isDark ? Colors.white : Colors.black,
                    onTap: _handleAppleSignIn,
                  ),
                  const SizedBox(width: 16),
                  _buildSocialButton(
                    icon: LucideIcons.phone,
                    color: AppTheme.glowTeal,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Toggle
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        color: AppTheme.textMuted(context),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                        ),
                        TextSpan(
                          text: _isLogin ? "Sign Up" : "Sign In",
                          style: GoogleFonts.outfit(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(context, borderRadius: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.outfit(
          fontSize: 15,
          color: AppTheme.textPrimary(context),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: AppTheme.textMuted(context)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: AppTheme.textMuted(context), size: 20),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: AppTheme.cardDecoration(context, borderRadius: 18),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
