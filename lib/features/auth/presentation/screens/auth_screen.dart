import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/services/firebase_auth_service.dart';
import 'package:reclaim/core/services/rate_limiter.dart';
import 'package:reclaim/core/services/secure_error_handler.dart';
import 'package:reclaim/core/services/secure_token_storage.dart';
import 'package:reclaim/core/services/validation_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectUrl;
  const AuthScreen({super.key, this.redirectUrl});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 2, vsync: this);

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  late final _firebaseAuth = FirebaseAuthService();

  bool _obscure = true, _loading = false;
  String? _errorMsg;

  Future<void> _persistSupabaseSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    if (session != null && user != null) {
      await SecureTokenStorage.saveToken(
        token: session.accessToken,
        refreshToken: session.refreshToken,
        userId: user.id,
      );
    }
  }

  String _buildRateLimitMessage(String identifier) {
    final remaining = RateLimiter.getRemainingAttempts(identifier);
    final lockSeconds = RateLimiter.getLockedOutTimeRemaining(identifier);
    if (lockSeconds != null) {
      final mins = (lockSeconds / 60).ceil();
      return 'Too many attempts. Try again in about $mins minute(s).';
    }
    return 'Invalid attempts detected. $remaining attempt(s) remaining.';
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                Expanded(flex: 2, child: _desktopLeftPanel()),
                Expanded(flex: 1, child: _desktopRightPanel()),
              ],
            )
          : _mobileLayout(),
    );
  }

  // ================= LEFT PANEL =================
  Widget _desktopLeftPanel() {
    return Container(
      color: AppTheme.primaryGreen,
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Reclaim",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          const Text(
            "Transform Waste\ninto Value",
            style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Join the circular economy movement.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= RIGHT PANEL =================
  Widget _desktopRightPanel() {
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: _authForm(),
        ),
      ),
    );
  }

  // ================= MOBILE =================
  Widget _mobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _authForm(),
      ),
    );
  }

  // ================= AUTH FORM =================
  Widget _authForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Tabs
        TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: "Sign In"),
            Tab(text: "Sign Up"),
          ],
        ),

        const SizedBox(height: 20),

        // 🔥 FIXED HEIGHT (NO Expanded)
        SizedBox(
          height: 420,
          child: TabBarView(
            controller: _tab,
            children: [
              _signInForm(),
              _signUpForm(),
            ],
          ),
        ),
      ],
    );
  }

  // ================= SIGN IN =================
  Widget _signInForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_errorMsg != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMsg!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _loading ? null : () async {
              final email = _emailCtrl.text.trim();
              final password = _passCtrl.text;

              final emailError = ValidationService.validateEmail(email);
              if (emailError != null) {
                setState(() => _errorMsg = emailError);
                return;
              }

              if (password.isEmpty) {
                setState(() => _errorMsg = 'Please enter your password');
                return;
              }

              final rateKey = email.toLowerCase();
              if (!RateLimiter.canAttempt(rateKey)) {
                setState(() => _errorMsg = _buildRateLimitMessage(rateKey));
                return;
              }

              setState(() { _loading = true; _errorMsg = null; });
              try {
                await Supabase.instance.client.auth.signInWithPassword(
                  email: email,
                  password: password,
                );
                await _persistSupabaseSession();
                RateLimiter.resetAttempts(rateKey);
                if (mounted) {
                  setState(() => _loading = false);
                  context.go('/role-selection');
                }
              } catch (e) {
                if (mounted) {
                  final safe = SecureErrorHandler.getUserFriendlyMessage(e);
                  setState(() { _loading = false; _errorMsg = safe; });
                }
              }
            },
            child: Text(_loading ? "Signing In..." : "Sign In"),
          ),
          const SizedBox(height: 16),

          // Google Sign-In Button
          ElevatedButton.icon(
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _errorMsg = null; });
              try {
                final user = await _firebaseAuth.signInWithGoogle();
                if (user != null && mounted) {
                  setState(() => _loading = false);
                  context.go('/role-selection');
                } else if (mounted) {
                  setState(() { _loading = false; _errorMsg = 'Google Sign-In failed'; });
                }
              } catch (e) {
                if (mounted) {
                  final errMsg = e.toString();
                  if (errMsg.contains('cancelled') || errMsg.contains('user_cancelled')) {
                    setState(() { _loading = false; _errorMsg = null; });
                  } else {
                    setState(() {
                      _loading = false;
                      _errorMsg = SecureErrorHandler.getUserFriendlyMessage(e);
                    });
                  }
                }
              }
            },
            icon: const Icon(Icons.account_circle),
            label: Text(_loading ? "Signing In..." : "Sign In with Google"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1F2937),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SIGN UP =================
  Widget _signUpForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_errorMsg != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMsg!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _loading ? null : () async {
              final name = _nameCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              final password = _passCtrl.text;

              final nameError = ValidationService.validateFullName(name);
              if (nameError != null) {
                setState(() => _errorMsg = nameError);
                return;
              }

              final emailError = ValidationService.validateEmail(email);
              if (emailError != null) {
                setState(() => _errorMsg = emailError);
                return;
              }

              final passError = ValidationService.validatePassword(password);
              if (passError != null) {
                setState(() => _errorMsg = passError);
                return;
              }

              final rateKey = email.toLowerCase();
              if (!RateLimiter.canAttempt(rateKey)) {
                setState(() => _errorMsg = _buildRateLimitMessage(rateKey));
                return;
              }

              setState(() { _loading = true; _errorMsg = null; });
              try {
                final user = await _firebaseAuth.signUpWithEmail(
                  email: email,
                  password: password,
                  fullName: name,
                );
                if (user != null && mounted) {
                  RateLimiter.resetAttempts(rateKey);
                  setState(() => _loading = false);
                  context.go('/role-selection');
                }
              } catch (e) {
                if (mounted) {
                  final safe = SecureErrorHandler.getUserFriendlyMessage(e);
                  setState(() { _loading = false; _errorMsg = safe; });
                }
              }
            },
            child: Text(_loading ? "Creating Account..." : "Sign Up"),
          ),
          const SizedBox(height: 16),

          // Google Sign-Up Button
          ElevatedButton.icon(
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _errorMsg = null; });
              try {
                final user = await _firebaseAuth.signInWithGoogle();
                if (user != null && mounted) {
                  setState(() => _loading = false);
                  context.go('/role-selection');
                } else if (mounted) {
                  setState(() { _loading = false; _errorMsg = 'Google Sign-Up failed'; });
                }
              } catch (e) {
                if (mounted) {
                  final errMsg = e.toString();
                  if (errMsg.contains('cancelled') || errMsg.contains('user_cancelled')) {
                    setState(() { _loading = false; _errorMsg = null; });
                  } else {
                    setState(() {
                      _loading = false;
                      _errorMsg = SecureErrorHandler.getUserFriendlyMessage(e);
                    });
                  }
                }
              }
            },
            icon: const Icon(Icons.account_circle),
            label: Text(_loading ? "Signing Up..." : "Sign Up with Google"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1F2937),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
          ),
        ],
      ),
    );
  }
}