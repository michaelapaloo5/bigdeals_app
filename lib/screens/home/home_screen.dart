import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../shop/shop_screen.dart';
import '../proxies/proxies_screen.dart';
import '../numbers/numbers_screen.dart';
import '../support/support_screen.dart';
import '../referrals/referrals_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../wallet/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  bool _loading = true;
  int _unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final res = await ApiService.getProfile();
    final notifRes = await ApiService.getUnreadCount();
    if (mounted) {
      setState(() {
        _user = res['success'] == true ? User.fromJson(res['user']) : null;
        _unreadNotifs = notifRes['count'] ?? 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.gold,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildWalletCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildServicesGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.goldLight]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              (_user?.name ?? 'U')[0].toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.dark),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_user?.name ?? 'User'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Text('Welcome to BigDeals', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())).then((_) => _loadData()),
          child: Stack(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                child: const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary, size: 20),
              ),
              if (_unreadNotifs > 0)
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                    child: Text('$_unreadNotifs', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())).then((_) => _loadData()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1C1C30), Color(0xFF141422)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.15)),
          boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('WALLET BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100), border: Border.all(color: AppTheme.success.withValues(alpha: 0.2))),
                  child: const Text('SECURED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.success, letterSpacing: 0.06)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'GHS ${(_user?.balance ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text('Tap to manage your wallet', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _quickAction(Icons.account_balance_wallet, 'Deposit', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())).then((_) => _loadData())),
        const SizedBox(width: 10),
        _quickAction(Icons.shopping_bag, 'Shop', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopScreen()))),
        const SizedBox(width: 10),
        _quickAction(Icons.wifi, 'Proxies', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProxiesScreen()))),
        const SizedBox(width: 10),
        _quickAction(Icons.phone_android, 'Numbers', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NumbersScreen()))),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.gold, size: 22),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    final services = [
      {'icon': Icons.support_agent, 'label': 'Support', 'color': AppTheme.accent},
      {'icon': Icons.card_giftcard, 'label': 'Referrals', 'color': AppTheme.gold},
      {'icon': Icons.history, 'label': 'History', 'color': AppTheme.success},
      {'icon': Icons.person, 'label': 'Profile', 'color': AppTheme.textSecondary},
    ];
    final screens = [
      const SupportScreen(),
      const ReferralsScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('More Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
          ),
          itemCount: services.length,
          itemBuilder: (ctx, i) {
            return GestureDetector(
              onTap: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => screens[i])).then((_) => _loadData()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Icon(services[i]['icon'] as IconData, color: services[i]['color'] as Color, size: 24),
                    const SizedBox(width: 10),
                    Text(services[i]['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
