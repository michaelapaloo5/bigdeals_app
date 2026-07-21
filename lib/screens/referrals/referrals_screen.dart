import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});
  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  String _code = '';
  String _link = '';
  int _totalReferrals = 0;
  int _completed = 0;
  double _totalEarned = 0;
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await ApiService.getReferralStats();
    final hist = await ApiService.getReferralHistory();
    if (mounted) {
      setState(() {
        _code = stats['referral_code'] ?? '';
        _link = stats['referral_link'] ?? '';
        _totalReferrals = stats['total_referrals'] ?? 0;
        _completed = stats['completed'] ?? 0;
        _totalEarned = (stats['total_earned'] ?? 0).toDouble();
        _history = hist['history'] ?? [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Referrals')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.gold,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1C1C30), Color(0xFF141422)]),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text('EARN 10%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.gold)),
                        const Text('on every friend\'s first deposit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statItem('Total', _totalReferrals.toString()),
                            _statItem('Completed', _completed.toString()),
                            _statItem('Earned', 'GHS ${_totalEarned.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Your Referral Link', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                    child: Row(
                      children: [
                        Expanded(child: Text(_link, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied!'), backgroundColor: AppTheme.success),
                            );
                          },
                          icon: const Icon(Icons.copy, color: AppTheme.gold, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No referrals yet', style: TextStyle(color: AppTheme.textSecondary))),
                    )
                  else
                    ..._history.map((h) => _historyItem(h)),
                ],
              ),
            ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _historyItem(Map<String, dynamic> h) {
    final isCompleted = h['status'] == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h['friend_email'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(h['created_at'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isCompleted ? AppTheme.success : AppTheme.gold).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(h['status'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isCompleted ? AppTheme.success : AppTheme.gold)),
              ),
              if (h['bonus_amount'] != null) ...[
                const SizedBox(height: 4),
                Text('+GHS ${double.parse(h['bonus_amount'].toString()).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.success)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
