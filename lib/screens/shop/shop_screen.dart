import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Product> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final catRes = await ApiService.getShopCategories();
    final prodRes = await ApiService.getShopProducts(category: _selectedCategory);
    if (mounted) {
      setState(() {
        _categories = List<String>.from(catRes['categories'] ?? []);
        _products = (prodRes['products'] as List? ?? []).map((p) => Product.fromJson(p)).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _catChip('All', null),
                      ..._categories.map((c) => _catChip(c, c)),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppTheme.gold,
                    child: _products.isEmpty
                        ? const Center(child: Text('No products found', style: TextStyle(color: AppTheme.textSecondary)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.65,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (ctx, i) => _productCard(_products[i]),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _catChip(String label, String? cat) {
    final active = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() { _selectedCategory = cat; _loading = true; _loadData(); }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.gold : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? AppTheme.gold : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppTheme.dark : AppTheme.textSecondary)),
      ),
    );
  }

  Widget _productCard(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: product.image != null
                    ? CachedNetworkImage(
                        imageUrl: '${ApiConfig.imageBase}/${product.image}',
                        width: double.infinity, fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppTheme.surfaceLight),
                        errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceLight, child: const Icon(Icons.image, color: AppTheme.textSecondary)),
                      )
                    : Container(color: AppTheme.surfaceLight, child: const Center(child: Icon(Icons.image, color: AppTheme.textSecondary, size: 32))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('GHS ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.gold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.4,
        expand: false,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            if (product.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: '${ApiConfig.imageBase}/${product.image}',
                  width: double.infinity, height: 200, fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(product.category, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Text('GHS ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.gold)),
            if (product.description != null) ...[
              const SizedBox(height: 12),
              Text(product.description!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.of(ctx).pop(); _addToCart(product); },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart'), backgroundColor: AppTheme.success),
    );
  }
}
