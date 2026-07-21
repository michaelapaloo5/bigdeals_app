import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final balRes = await ApiService.getBalance();
    final txRes = await ApiService.getTransactions();
    if (mounted) {
      setState(() {
        _balance = balRes['balance'] ?? 0;
        _transactions = (txRes['transactions'] as List? ?? []).map((t) => Transaction.fromJson(t)).toList();
        _loading = false;
      });
    }
  }

  void _showDepositSheet() {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Deposit Funds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Top up your wallet via Paystack', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Amount', prefixIcon: Icon(Icons.monetization_on)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [10, 20, 50, 100].map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: OutlinedButton(
                    onPressed: () => amountController.text = a.toString(),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.border)),
                    child: Text('GHS $a', style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountController.text);
                  if (amt == null || amt <= 0) return;
                  Navigator.of(ctx).pop();
                  final res = await ApiService.initiateDeposit(amt, 'paystack');
                  if (res['success'] == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment initialized. Complete in browser.'), backgroundColor: AppTheme.success),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['error'] ?? 'Failed'), backgroundColor: AppTheme.danger),
                      );
                    }
                  }
                },
                child: const Text('Deposit'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.gold,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1C1C30), Color(0xFF141422)]),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.12)),
                        const SizedBox(height: 8),
                        Text('GHS ${_balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showDepositSheet,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Deposit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (_transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: const Center(child: Text('No transactions yet', style: TextStyle(color: AppTheme.textSecondary))),
                    )
                  else
                    ..._transactions.map((tx) => _txItem(tx)),
                ],
              ),
      ),
    );
  }

  Widget _txItem(Transaction tx) {
    final isDeposit = tx.type == 'deposit';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isDeposit ? AppTheme.success : AppTheme.accent).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDeposit ? AppTheme.success : AppTheme.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.type.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                if (tx.reference != null) Text(tx.reference!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isDeposit ? '+' : '-'}GHS ${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDeposit ? AppTheme.success : AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
