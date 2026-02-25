import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  // Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isMobile = screenWidth < 480;
    
    return Scaffold(
      backgroundColor: isDesktop ? const Color(0xFFF5F5F5) : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: isDesktop ? 420 : 500),
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 24,
                vertical: 24,
              ),
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              decoration: isDesktop ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: isMobile ? 56 : 64,
                    height: isMobile ? 56 : 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.eco, size: isMobile ? 28 : 32, color: Colors.white),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Welcome to ReClaim',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your sustainable material marketplace',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tab Bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Forms
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _tabController.index == 0 ? _buildLoginForm() : _buildSignupForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
      errorStyle: const TextStyle(fontSize: 11),
      isDense: true,
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration('Email', Icons.email_outlined),
            validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : (!v!.contains('@') ? 'Invalid email' : null),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration('Password', Icons.lock_outlined,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: Colors.grey.shade500),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('Forgot Password?', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _fullNameController,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration('Full Name', Icons.person_outlined),
            validator: (v) => (v?.isEmpty ?? true) ? 'Enter name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration('Email', Icons.email_outlined),
            validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : (!v!.contains('@') ? 'Invalid email' : null),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupPasswordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration('Password', Icons.lock_outlined,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: Colors.grey.shade500),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : (v!.length < 6 ? 'Min 6 characters' : null),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupConfirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration('Confirm Password', Icons.lock_outlined,
              suffix: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: Colors.grey.shade500),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (v) => (v?.isEmpty ?? true) ? 'Confirm password' : (v != _signupPasswordController.text ? 'Passwords don\'t match' : null),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Sign Up', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.go('/role-selection');
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleSignup() async {
    if (_signupFormKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.go('/role-selection');
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}