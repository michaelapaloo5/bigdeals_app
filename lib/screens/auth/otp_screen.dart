import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    final res = await ApiService.verifyOtp(_otpController.text.trim());
    setState(() { _loading = false; });

    if (res['success'] == true) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() { _error = res['error']; });
    }
  }

  Future<void> _resend() async {
    final res = await ApiService.resendOtp();
    if (res['success'] == true) {
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'OTP resent'), backgroundColor: AppTheme.success),
        );
      }
    } else {
      setState(() { _error = res['error']; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.goldPale, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
                  boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.shield, color: AppTheme.gold, size: 34),
              ),
              const SizedBox(height: 20),
              const Text('Enter OTP Code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('We sent a 6-digit code to your email', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.dark))
                      : const Text('Verify Code'),
                ),
              ),
              const SizedBox(height: 16),
              if (_resendCountdown > 0)
                Text('Resend available in ${_resendCountdown}s', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))
              else
                GestureDetector(
                  onTap: _resend,
                  child: const Text('Resend OTP', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
