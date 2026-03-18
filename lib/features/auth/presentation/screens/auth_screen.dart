import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectUrl;
  const AuthScreen({super.key, this.redirectUrl});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _tab.addListener(() {
      if (_tab.indexIsChanging) setState(() => _errorMsg = null);
    });
  }

  @override
  void dispose() { _tab.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: isMobile ? _mobileLayout(context) : _desktopLayout(context),
    );
  }

  // ─── DESKTOP ─────────────────────────────────────────
  Widget _desktopLayout(BuildContext context) {
    return Row(children: [
      // Left panel — brand side
      Expanded(child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen, AppTheme.accent],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        padding: const EdgeInsets.all(56),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Logo
          Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.eco, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            const Text('Reclaim', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
          const Spacer(),
          // Headline
          const Text('Transform Waste\ninto Value', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -1)),
          const SizedBox(height: 18),
          const Text('Join the circular economy movement.\nDonate surplus materials, find what you need.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.65)),
          const SizedBox(height: 40),
          // Feature pills
          for (final f in ['Verified lab materials', '1,200+ items available', 'Carbon tracking built-in'])
            Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
              Container(width: 22, height: 22, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.check, color: Colors.white, size: 14)),
              const SizedBox(width: 10),
              Text(f, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ])),
          const Spacer(),
          // Stats row
          Row(children: [
            _leftStat('1,200+', 'Materials'),
            const SizedBox(width: 32),
            _leftStat('40+', 'Partner Labs'),
            const SizedBox(width: 32),
            _leftStat('850 kg', 'CO₂ Saved'),
          ]),
        ]),
      )),
      // Right panel — auth form
      SizedBox(width: 480,
        child: Container(
          color: Colors.white,
          child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(48),
            child: _authForm(isMobile: false),
          )),
        )),
    ]);
  }

  Widget _leftStat(String v, String l) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 12)),
  ]);

  // ─── MOBILE ───────────────────────────────────────────
  Widget _mobileLayout(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      // Top brand strip
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.eco, color: Colors.white, size: 32)),
          const SizedBox(height: 14),
          const Text('Reclaim', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const Text('Sustainable Materials Marketplace', style: TextStyle(color: Colors.white60, fontSize: 13)),
        ]),
      ),
      // Auth form
      Padding(padding: const EdgeInsets.all(24), child: _authForm(isMobile: true)),
    ]));
  }

  // ─── Shared Form ──────────────────────────────────────
  Widget _authForm({required bool isMobile}) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!isMobile) ...[
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 22)),
          const SizedBox(width: 12),
          const Text('Reclaim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
        ]),
        const SizedBox(height: 36),
        const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('Sign in to your account or create a new one.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 28),
      ] else ...[
        const Text('Get Started', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Sign in or create your account', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
      ],
      // Tabs
      Container(
        height: 46,
        decoration: BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(10)),
        child: TabBar(
          controller: _tab,
          labelColor: Colors.white, unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          indicator: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
        ),
      ),
      const SizedBox(height: 28),
      SizedBox(height: 420, child: TabBarView(controller: _tab, children: [
        _signInForm(),
        _signUpForm(),
      ])),
    ]);
  }

  Widget _signInForm() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Demo banner
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 15, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        const Expanded(child: Text('Demo mode — tap "Enter Demo" to explore the app.',
          style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen))),
      ]),
    ),
    const SizedBox(height: 14),
    _label('Email'), _field(_emailCtrl, 'you@example.com', TextInputType.emailAddress),
    const SizedBox(height: 16),
    _label('Password'), _passField(),
    const SizedBox(height: 16),
    _submitBtn('Sign In', () async {
      if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
        setState(() => _errorMsg = 'Please enter your email and password.');
        return;
      }
      setState(() { _loading = true; _errorMsg = null; });
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ).timeout(const Duration(seconds: 15));
        if (mounted) { setState(() => _loading = false); context.go('/role-selection'); }
      } on AuthException catch (e) {
        debugPrint('[SignIn] AuthException: ${e.message} (status: ${e.statusCode})');
        if (mounted) {
          final friendly = _friendlyError(e.message);
          setState(() { _loading = false; _errorMsg = friendly; });
        }
      } catch (e) {
        debugPrint('[SignIn] Exception: $e');
        if (mounted) {
          final msg = e.toString().toLowerCase();
          final text = (msg.contains('timeout') || msg.contains('timed out'))
              ? 'Connection timed out. Check your internet and try again.'
              : 'Something went wrong: ${e.toString()}';
          setState(() { _loading = false; _errorMsg = text; });
        }
      }
    }),
    const SizedBox(height: 10),
    SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/role-selection'),
        icon: const Icon(Icons.play_circle_outline, size: 18),
        label: const Text('Enter Demo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryGreen,
          side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    if (_errorMsg != null) ...[
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMsg!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ]),
      ),
    ],
  ]);

  Widget _signUpForm() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Full Name'), _field(_nameCtrl, 'Your full name'),
    const SizedBox(height: 14),
    _label('Email'), _field(_emailCtrl, 'you@example.com', TextInputType.emailAddress),
    const SizedBox(height: 14),
    _label('Password'), _passField(),
    const SizedBox(height: 20),
    _submitBtn('Create Account', () async {
      if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
        setState(() => _errorMsg = 'Please fill in all fields.');
        return;
      }
      if (_passCtrl.text.length < 6) {
        setState(() => _errorMsg = 'Password must be at least 6 characters.');
        return;
      }
      setState(() { _loading = true; _errorMsg = null; });
      try {
        final res = await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          data: {'full_name': _nameCtrl.text.trim()},
        ).timeout(const Duration(seconds: 15));
        if (!mounted) return;
        setState(() => _loading = false);

        if (res.session != null) {
          // Email confirmation not required — create profile and continue
          await _ensureProfile(res.session!.user.id);
          if (mounted) context.go('/role-selection');
        } else {
          // Email confirmation required
          _snack(
            '📧 Account created! Check your email (${_emailCtrl.text.trim()}) to confirm, then Sign In.',
            AppTheme.primaryGreen,
            duration: const Duration(seconds: 8),
          );
          _tab.animateTo(0); // switch to Sign In tab
        }
      } on AuthException catch (e) {
        debugPrint('[SignUp] AuthException: ${e.message} (status: ${e.statusCode})');
        if (mounted) setState(() { _loading = false; _errorMsg = _friendlyError(e.message); });
      } catch (e) {
        debugPrint('[SignUp] Exception: $e');
        if (mounted) {
          final msg = e.toString().toLowerCase();
          final text = (msg.contains('timeout') || msg.contains('timed out'))
              ? 'Connection timed out. Check your internet and try again.'
              : 'Something went wrong: ${e.toString()}';
          setState(() { _loading = false; _errorMsg = text; });
        }
      }
    }),
    if (_errorMsg != null) ...[
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMsg!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ]),
      ),
    ],
  ]);

  /// Insert a row into `profiles` if one does not yet exist
  Future<void> _ensureProfile(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final existing = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (existing == null) {
        await supabase.from('profiles').insert({
          'id': userId,
          'name': _nameCtrl.text.trim().isEmpty ? 'User' : _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': 'student',
        });
      }
    } catch (e) {
      // Profile insert is best-effort; non-fatal
      debugPrint('Profile insert skipped: $e');
    }
  }

  /// Convert raw Supabase error messages to user-friendly text
  String _friendlyError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'Incorrect email or password. Try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email first, then Sign In.';
    }
    if (msg.contains('user already registered') || msg.contains('already been registered')) {
      return 'An account with this email already exists. Try Sign In.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'Connection timed out. Check your internet and try again.';
    }
    // For fetch/network errors from Supabase, show the raw message so the real cause is visible
    if (msg.contains('failed to fetch') || msg == 'network error' || msg == 'fetch error') {
      return 'Cannot reach server. Your Supabase project may be paused — check your Supabase dashboard. (Raw: $raw)';
    }
    return raw;
  }

  void _snack(String msg, Color bg, {Duration duration = const Duration(seconds: 4)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)));

  Widget _field(TextEditingController c, String hint, [TextInputType? kt]) => TextFormField(
    controller: c, keyboardType: kt,
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
  );

  Widget _passField() => TextFormField(
    controller: _passCtrl, obscureText: _obscure,
    decoration: InputDecoration(
      hintText: 'Your password',
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey.shade500)),
    ),
  );

  Widget _submitBtn(String label, VoidCallback onTap) => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
    onPressed: _loading ? null : onTap,
    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
      : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
  ));
}
