import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matricController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_matricController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter your matric number and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ApiService.login(
        matricNumber: _matricController.text.trim(),
        password: _passwordController.text,
      );
      await AuthService.instance.persistSession(user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  children: [
                    TextSpan(text: 'CAMPUS'),
                    TextSpan(text: 'ALERT', style: TextStyle(color: AppColors.alert)),
                  ],
                ),
              ),
              const SizedBox(height: 56),
              const Text(
                'Sign in with your matric number.',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600, height: 1.2),
              ),
              const SizedBox(height: 8),
              const Text(
                "Every alert is tied to your student ID — that's what makes response and accountability possible.",
                style: TextStyle(color: Color(0xFF9AA5B8), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              _label('MATRIC NUMBER'),
              _field(_matricController, hint: 'FPI/CS/21/0842'),
              const SizedBox(height: 18),
              _label('PASSWORD'),
              _field(_passwordController, obscure: true, hint: '••••••••••'),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.alert, fontSize: 12.5)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text('Forgot password? Contact ICT helpdesk',
                    style: TextStyle(color: Color(0xFF7C8AA0), fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(color: Color(0xFF8792A6), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
      );

  Widget _field(TextEditingController controller, {String? hint, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF5A6B87)),
        filled: true,
        fillColor: const Color(0xFF16233C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2C3A55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2C3A55)),
        ),
      ),
    );
  }
}
