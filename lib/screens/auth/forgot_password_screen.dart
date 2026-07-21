import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; _success = null; });
    final res = await ApiService.forgotPassword(_email.text.trim());
    setState(() { _loading = false; });
    if (res['success'] == true) {
      setState(() { _success = res['message']; });
    } else {
      setState(() { _error = res['error']; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_reset, color: AppTheme.gold, size: 48),
              const SizedBox(height: 16),
              const Text('Forgot your password?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Enter your email and we\'ll send you a reset link.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.dark))
                      : const Text('Send Reset Link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
