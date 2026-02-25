import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reclaim/features/ecommerce/providers/cart_provider.dart';

/// Product Catalog Screen
/// 
/// Displays a grid of products for sale with search and filter options
class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType;
  bool _showFilters = false;

  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

  int get _gridColumnCount {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Shop Materials'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: Badge(
              label: Text('$cartItemCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.all(_isDesktop ? 20 : 16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 500),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search materials...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_isDesktop) ...[
                      SizedBox(width: 16),
                      _buildFilterChips(),
                    ],
                  ],
                ),
              ),

              // Filters (collapsible on mobile only)
              if (_showFilters && !_isDesktop)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildFilterChips(),
                ),

              // Product Grid
              Expanded(
                child: _buildProductGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/cart');
        },
        label: const Text('View Cart'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: _selectedType == null,
          onSelected: (_) {
            setState(() {
              _selectedType = null;
            });
          },
        ),
        FilterChip(
          label: const Text('Electronic'),
          selected: _selectedType == 'Electronic',
          onSelected: (_) {
            setState(() {
              _selectedType = 'Electronic';
            });
          },
        ),
        FilterChip(
          label: const Text('Metal'),
          selected: _selectedType == 'Metal',
          onSelected: (_) {
            setState(() {
              _selectedType = 'Metal';
            });
          },
        ),
        FilterChip(
          label: const Text('Plastic'),
          selected: _selectedType == 'Plastic',
          onSelected: (_) {
            setState(() {
              _selectedType = 'Plastic';
            });
          },
        ),
        FilterChip(
          label: const Text('Glass'),
          selected: _selectedType == 'Glass',
          onSelected: (_) {
            setState(() {
              _selectedType = 'Glass';
            });
          },
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    // TODO: Replace with actual provider data
    return GridView.builder(
      padding: EdgeInsets.all(_isDesktop ? 20 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumnCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: _isDesktop ? 20 : 12,
        mainAxisSpacing: _isDesktop ? 20 : 12,
      ),
      itemCount: 10, // Placeholder
      itemBuilder: (context, index) {
        return _buildProductCard(index);
      },
    );
  }

  Widget _buildProductCard(int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product detail
          // context.go('/product/${index}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Material ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Good',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${5 - (index % 5)} left',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${(index + 1) * 99}.00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.add_shopping_cart,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
