import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ProxiesScreen extends StatefulWidget {
  const ProxiesScreen({super.key});
  @override
  State<ProxiesScreen> createState() => _ProxiesScreenState();
}

class _ProxiesScreenState extends State<ProxiesScreen> {
  List<ProxyProduct> _products = [];
  bool _loading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _loading = true; });
    final res = await ApiService.getProxyProducts();
    if (mounted) {
      setState(() {
        _products = (res['products'] as List? ?? []).map((p) => ProxyProduct.fromJson(p)).toList();
        _loading = false;
      });
    }
  }

  Map<String, List<ProxyProduct>> get _grouped {
    final map = <String, List<ProxyProduct>>{};
    for (var p in _products) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxies'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn('Products', 0),
                const SizedBox(width: 8),
                _tabBtn('My Orders', 1),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildProducts() : _buildOrders(),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final active = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = idx;
          if (idx == 1) _loadOrders();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppTheme.gold : AppTheme.border),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: active ? AppTheme.dark : AppTheme.textSecondary,
            )),
          ),
        ),
      ),
    );
  }

  List<Order> _orders = [];
  bool _loadingOrders = false;

  Future<void> _loadOrders() async {
    setState(() { _loadingOrders = true; });
    final res = await ApiService.getProxyOrders();
    if (mounted) {
      setState(() {
        _orders = (res['orders'] as List? ?? []).map((o) => Order.fromJson(o)).toList();
        _loadingOrders = false;
      });
    }
  }

  Widget _buildOrders() {
    if (_loadingOrders) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    if (_orders.isEmpty) return const Center(child: Text('No orders yet', style: TextStyle(color: AppTheme.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (ctx, i) => _orderCard(_orders[i]),
    );
  }

  Widget _orderCard(Order order) {
    final isReceived = order.status == 'received';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(order.productName ?? 'Order', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isReceived ? AppTheme.success : AppTheme.gold).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(order.status, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: isReceived ? AppTheme.success : AppTheme.gold,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GHS ${order.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.gold)),
              if (order.createdAt != null) Text(order.createdAt!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          if (order.proxyCode != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROXY CODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.success, letterSpacing: 0.1)),
                  const SizedBox(height: 4),
                  SelectableText(order.proxyCode!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProducts() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    final grouped = _grouped;
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppTheme.gold,
      child: grouped.isEmpty
          ? const Center(child: Text('No products available', style: TextStyle(color: AppTheme.textSecondary)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((e) => _categorySection(e.key, e.value)).toList(),
            ),
    );
  }

  Widget _categorySection(String category, List<ProxyProduct> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...products.map((p) => _productCard(p)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _productCard(ProxyProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (product.duration != null) ...[
                  const SizedBox(height: 4),
                  Text(product.duration!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('GHS ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.gold)),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text('GHS ${product.originalPrice!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _buyProxy(product),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            child: const Text('Buy', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _buyProxy(ProxyProduct product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Buy ${product.name}?'),
        content: Text('This will deduct GHS ${product.price.toStringAsFixed(2)} from your wallet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm', style: TextStyle(color: AppTheme.gold))),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await ApiService.buyProxy(product.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? res['error'] ?? 'Done'),
        backgroundColor: res['success'] == true ? AppTheme.success : AppTheme.danger,
      ));
      if (res['success'] == true) _loadProducts();
    }
  }
}
