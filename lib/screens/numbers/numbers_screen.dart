import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});
  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  List<SmsService> _services = [];
  List<SmsService> _filtered = [];
  bool _loading = true;
  String _search = '';
  String? _selectedCountry;
  List<String> _countries = [];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() { _loading = true; });
    final res = await ApiService.getSmsServices();
    if (mounted) {
      final list = (res['services'] as List? ?? []).map((s) => SmsService.fromJson(s)).toList();
      final countrySet = list.map((s) => s.countryName).toSet().toList()..sort();
      setState(() {
        _services = list;
        _countries = countrySet;
        _filter();
        _loading = false;
      });
    }
  }

  void _filter() {
    _filtered = _services.where((s) {
      final matchSearch = _search.isEmpty || s.service.toLowerCase().contains(_search.toLowerCase());
      final matchCountry = _selectedCountry == null || s.countryName == _selectedCountry;
      return matchSearch && matchCountry;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Numbers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn('Services', 0),
                const SizedBox(width: 8),
                _tabBtn('History', 1),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildServices() : _buildHistory(),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final active = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _selectedTab = idx; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppTheme.gold : AppTheme.border),
          ),
          child: Center(child: Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: active ? AppTheme.dark : AppTheme.textSecondary,
          ))),
        ),
      ),
    );
  }

  Widget _buildServices() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() { _search = v; _filter(); }),
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _countryChip('All', null),
              ..._countries.map((c) => _countryChip(c, c)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadServices,
            color: AppTheme.gold,
            child: _filtered.isEmpty
                ? const Center(child: Text('No services found', style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _serviceCard(_filtered[i]),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _countryChip(String label, String? country) {
    final active = _selectedCountry == country;
    return GestureDetector(
      onTap: () => setState(() { _selectedCountry = country; _filter(); }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.gold : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? AppTheme.gold : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? AppTheme.dark : AppTheme.textSecondary)),
      ),
    );
  }

  Widget _serviceCard(SmsService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.phone_android, color: AppTheme.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.service, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(service.countryName, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('GHS ${service.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.gold)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _purchase(service),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Buy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.dark)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purchase(SmsService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Buy ${service.service}?'),
        content: Text('GHS ${service.price.toStringAsFixed(2)} will be deducted from your wallet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm', style: TextStyle(color: AppTheme.gold))),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await ApiService.purchaseSms(service.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? res['error'] ?? 'Done'),
        backgroundColor: res['success'] == true ? AppTheme.success : AppTheme.danger,
      ));
    }
  }

  List<Map<String, dynamic>> _history = [];
  bool _loadingHistory = false;

  Widget _buildHistory() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getSmsHistory(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
        final sessions = (snap.data!['sessions'] as List? ?? []);
        if (sessions.isEmpty) return const Center(child: Text('No history yet', style: TextStyle(color: AppTheme.textSecondary)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (ctx, i) {
            final s = sessions[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['service'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(s['phone_number'] ?? 'Awaiting...', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (s['status'] == 'completed' ? AppTheme.success : AppTheme.gold).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(s['status'] ?? '', style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: s['status'] == 'completed' ? AppTheme.success : AppTheme.gold,
                        )),
                      ),
                      if (s['sms_code'] != null && s['sms_code'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Code: ${s['sms_code']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.success)),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
