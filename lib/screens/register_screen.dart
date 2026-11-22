import 'package:flutter/material.dart';
import 'package:stash_a_story/services/api_service.dart';
import 'login_screen.dart';

/// Register screen. Fully self-contained: it shares no widgets or constants
/// with the Login screen (everything it needs is defined in this file).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _titleGreen = Color(0xFF2F6139);
  static const Color _buttonGreen = Color(0xFF228B22);
  static const Color _fieldFill = Color(0xFFC8D1D9);
  static const Color _toggleSelected = Color(0xFFD9D9D9);
  static const Color _errorRed = Color(0xFFC62828);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final result = await ApiService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Something went wrong')),
    );
    if (result['success'] == true) _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.3, 0), // starts 30% off to the left
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 15),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(icon, color: _titleGreen),
      ),
      suffixIcon: suffix == null
          ? null
          : Padding(padding: const EdgeInsets.only(right: 8), child: suffix),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      errorStyle: const TextStyle(color: _errorRed, fontSize: 12.5),
      border: border(Colors.transparent, 0),
      enabledBorder: border(Colors.transparent, 0),
      focusedBorder: border(_buttonGreen, 2),
      errorBorder: border(_errorRed, 1.5),
      focusedErrorBorder: border(_errorRed, 2),
    );
  }

  Widget _buildToggle() {
    return Container(
      width: 300,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        children: [
          // LOGIN
          Expanded(
            child: InkWell(
              onTap: _goToLogin,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Text('LOGIN', style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
          Container(width: 1, color: Colors.black),
          // REGISTER (selected)
          Expanded(
            child: Container(
              color: _toggleSelected,
              alignment: Alignment.center,
              child: const Text('REGISTER', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visibilityButton(bool hidden, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.black54,
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png', width: 110),
                    const SizedBox(height: 12),
                    const Text(
                      'Stash A Story',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: _titleGreen,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildToggle(),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      style: const TextStyle(fontSize: 16),
                      decoration: _decoration(
                        hint: 'Username',
                        icon: Icons.person_outline,
                      ),
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Please enter your username';
                        if (v.length < 2) return 'Username is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(fontSize: 16),
                      decoration: _decoration(
                        hint: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 16),
                      decoration: _decoration(
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        suffix: _visibilityButton(_hidePassword,
                            () => setState(() => _hidePassword = !_hidePassword)),
                      ),
                      onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                      validator: (value) {
                        final v = value ?? '';
                        if (v.isEmpty) return 'Please enter a password';
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmController,
                      focusNode: _confirmFocus,
                      obscureText: _hideConfirm,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 16),
                      decoration: _decoration(
                        hint: 'Confirm password',
                        icon: Icons.lock_outline,
                        suffix: _visibilityButton(_hideConfirm,
                            () => setState(() => _hideConfirm = !_hideConfirm)),
                      ),
                      onFieldSubmitted: (_) => _onRegisterPressed(),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 230,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text('REGISTER',
                            style: TextStyle(fontSize: 17)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
