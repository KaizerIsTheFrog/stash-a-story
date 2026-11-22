import 'package:flutter/material.dart';
import 'package:stash_a_story/screens/login_screen.dart';
import 'package:stash_a_story/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String name = '';
  String email = '';
  String role = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await ApiService.profile();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        name = result['user']['name'];
        email = result['user']['email'];
        role = result['user']['role'];
        loading = false;
      });
    } else {
      _goToLogin(); // token invalid or expired
    }
  }

  bool get _isLibrarian => role.toLowerCase() == 'librarian';

  Future<void> _onLogoutPressed() async {
      await ApiService.logout();
      if (!mounted) return;
      _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }


    
  static const Color _titleGreen = Color(0xFF2F6139);
  static const Color _buttonGreen = Color(0xFF228B22);
  static const Color _gold = Color(0xFFD39B2C);



  Widget _infoRow(IconData icon, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: _titleGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                value,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _isLibrarian ? _gold : _buttonGreen;

    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', width: 110),
                  const SizedBox(height: 12),
                  const Text(
                    'Stash A Story',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _titleGreen,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome, $name!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x73C8D1D9),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.person_outline,
                          'NAME',
                          Text(name, style: const TextStyle(fontSize: 16)),
                        ),
                        const Divider(height: 1),
                        _infoRow(
                          Icons.email_outlined,
                          'EMAIL',
                          Text(email, style: const TextStyle(fontSize: 16)),
                        ),
                        const Divider(height: 1),
                        _infoRow(
                          Icons.badge_outlined,
                          'ROLE',
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: roleColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 230,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () => _onLogoutPressed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text('LOGOUT', style: TextStyle(fontSize: 17)),
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

}
