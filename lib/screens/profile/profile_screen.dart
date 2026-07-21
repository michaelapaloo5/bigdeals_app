import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        _user = res['success'] == true ? User.fromJson(res['user']) : null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : _user == null
              ? const Center(child: Text('Failed to load profile'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.goldLight]),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            (_user!.name.isNotEmpty ? _user!.name[0] : 'U').toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.dark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(child: Text(_user!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                    Center(child: Text(_user!.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                    const SizedBox(height: 24),
                    _statRow('Total Deposits', 'GHS ${_user!.balance.toStringAsFixed(2)}', Icons.account_balance_wallet),
                    _statRow('Total Orders', '${_user!.total_orders ?? 0}', Icons.shopping_bag),
                    const SizedBox(height: 24),
                    _menuItem(Icons.person_outline, 'Edit Profile', () => _editProfile()),
                    _menuItem(Icons.lock_outline, 'Change Password', () => _changePassword()),
                    _menuItem(Icons.logout, 'Sign Out', () => _logout(), color: AppTheme.danger),
                  ],
                ),
    );
  }

  Widget _statRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.gold)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _user?.name ?? '');
    final emailController = TextEditingController(text: _user?.email ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(hintText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
    if (result == true) {
      final res = await ApiService.updateProfile(nameController.text, emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? res['error'] ?? 'Done'),
          backgroundColor: res['success'] == true ? AppTheme.success : AppTheme.danger,
        ));
        _loadProfile();
      }
    }
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: current, obscureText: true, decoration: const InputDecoration(hintText: 'Current Password')),
            const SizedBox(height: 12),
            TextField(controller: newPass, obscureText: true, decoration: const InputDecoration(hintText: 'New Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Change', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
    if (result == true) {
      final res = await ApiService.changePassword(current.text, newPass.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? res['error'] ?? 'Done'),
          backgroundColor: res['success'] == true ? AppTheme.success : AppTheme.danger,
        ));
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign Out', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.clearSession();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
