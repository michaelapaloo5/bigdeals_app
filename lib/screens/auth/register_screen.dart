import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _referral = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _success;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; _success = null; });
    final res = await ApiService.register(
      _email.text.trim(), _password.text, _confirm.text,
      referralCode: _referral.text.trim().isNotEmpty ? _referral.text.trim() : null,
    );
    setState(() { _loading = false; });
    if (res['success'] == true) {
      setState(() { _success = 'Account created! Please sign in.'; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      setState(() { _error = res['error']; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                ),
              if (_success != null)
                Container(
                  padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(_success!, style: const TextStyle(color: AppTheme.success, fontSize: 13)),
                ),
              TextField(
                controller: _email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password, obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirm, obscureText: true,
                decoration: const InputDecoration(hintText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _referral,
                decoration: const InputDecoration(hintText: 'Referral Code (optional)', prefixIcon: Icon(Icons.card_giftcard)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.dark))
                      : const Text('Create Account'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text('Sign In', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
