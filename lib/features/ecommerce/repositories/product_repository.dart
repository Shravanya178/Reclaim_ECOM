import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Repository for product/material catalog operations
class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  /// Get all products with filters
  Future<List<Product>> getProducts({
    ProductFilters? filters,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true);

      // Apply filters
      if (filters != null) {
        if (filters.types != null && filters.types!.isNotEmpty) {
          query = query.inFilter('type', filters.types!);
        }

        if (filters.conditions != null && filters.conditions!.isNotEmpty) {
          query = query.inFilter('condition', filters.conditions!);
        }

        if (filters.minPrice != null) {
          query = query.gte('base_price', filters.minPrice!);
        }

        if (filters.maxPrice != null) {
          query = query.lte('base_price', filters.maxPrice!);
        }

        if (filters.campusId != null) {
          query = query.eq('campus_id', filters.campusId!);
        }

        if (filters.inStockOnly == true) {
          query = query.gt('stock_quantity', 0);
        }

        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.or(
            'name.ilike.%${filters.searchQuery}%,'
            'notes.ilike.%${filters.searchQuery}%,'
            'type.ilike.%${filters.searchQuery}%',
          );
        }

        // Apply sorting
        if (filters.sortBy != null) {
          final sortCol;
          final sortAsc;
          switch (filters.sortBy!) {
            case ProductSortOption.newest:
              sortCol = 'created_at';
              sortAsc = false;
              break;
            case ProductSortOption.oldest:
              sortCol = 'created_at';
              sortAsc = true;
              break;
            case ProductSortOption.priceLowToHigh:
              sortCol = 'base_price';
              sortAsc = true;
              break;
            case ProductSortOption.priceHighToLow:
              sortCol = 'base_price';
              sortAsc = false;
              break;
            case ProductSortOption.nameAtoZ:
              sortCol = 'name';
              sortAsc = true;
              break;
            case ProductSortOption.nameZtoA:
              sortCol = 'name';
              sortAsc = false;
              break;
            case ProductSortOption.carbonSaved:
              sortCol = 'carbon_saved';
              sortAsc = false;
              break;
            default:
              sortCol = 'created_at';
              sortAsc = false;
          }
          final result = await query.order(sortCol, ascending: sortAsc).range(offset, offset + limit - 1);
          return (result as List).map((json) => _productFromJson(json)).toList();
        }
      }

      final result = await query.order('created_at', ascending: false).range(offset, offset + limit - 1);
      return (result as List).map((json) => _productFromJson(json)).toList();
    } catch (e) {
      debugPrint('Products fetch failed. Falling back to local catalog: $e');
      return [];
    }
  }

  /// Get single product by ID
  Future<Product?> getProduct(String productId) async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('id', productId)
          .single();

      return _productFromJson(result);
    } catch (e) {
      debugPrint('Product fetch failed: $e');
      return null;
    }
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true)
          .or(
            'name.ilike.%$query%,'
            'notes.ilike.%$query%,'
            'type.ilike.%$query%',
          )
          .order('created_at', ascending: false)
          .limit(20);

      return (result as List).map((json) => _productFromJson(json)).toList();
    } catch (e) {
      debugPrint('Product search failed: $e');
      return [];
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true)
          .gt('stock_quantity', 0)
          .order('carbon_saved', ascending: false)
          .limit(limit);

      return (result as List).map((json) => _productFromJson(json)).toList();
    } catch (e) {
      debugPrint('Featured products fetch failed: $e');
      return [];
    }
  }

  /// Get products by type
  Future<List<Product>> getProductsByType(String type) async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true)
          .eq('type', type)
          .gt('stock_quantity', 0)
          .order('created_at', ascending: false)
          .limit(20);

      return (result as List).map((json) => _productFromJson(json)).toList();
    } catch (e) {
      debugPrint('Products-by-type fetch failed: $e');
      return [];
    }
  }

  /// Get available product types
  Future<List<String>> getProductTypes() async {
    try {
      final result = await _supabase
          .from('materials')
          .select('type')
          .eq('is_listed_for_sale', true)
          .order('type');

      final types = <String>{};
      for (var item in result as List) {
        types.add(item['type'] as String);
      }

      return types.toList();
    } catch (e) {
      debugPrint('Product types fetch failed: $e');
      return [];
    }
  }

  /// Get product statistics
  Future<ProductStats> getProductStats() async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true);

      final products = result as List;
      var totalProducts = products.length;
      var inStock = 0;
      var totalValue = 0.0;

      for (var product in products) {
        if ((product['stock_quantity'] as int) > 0) {
          inStock++;
        }
        totalValue += ((product['base_price'] as num?)?.toDouble() ?? 0) *
            (product['stock_quantity'] as int);
      }

      return ProductStats(
        totalProducts: totalProducts,
        inStock: inStock,
        outOfStock: totalProducts - inStock,
        totalValue: totalValue,
      );
    } catch (e) {
      debugPrint('Product stats fetch failed: $e');
      return ProductStats(
        totalProducts: 0,
        inStock: 0,
        outOfStock: 0,
        totalValue: 0,
      );
    }
  }

  /// Convert JSON to Product model
  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      quantity: json['quantity'] ?? '1 unit',
      condition: json['condition'],
      location: json['location'],
      imageUrl: json['image_url'],
      notes: json['notes'],
      status: json['status'],
      carbonSaved: (json['carbon_saved'] as num?)?.toDouble() ?? 0.0,
      campusId: json['campus_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      isListedForSale: json['is_listed_for_sale'] ?? false,
      irsScore: json['irs_score'],
      lifecycleState: json['lifecycle_state'],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

/// Product statistics model
class ProductStats {
  final int totalProducts;
  final int inStock;
  final int outOfStock;
  final double totalValue;

  ProductStats({
    required this.totalProducts,
    required this.inStock,
    required this.outOfStock,
    required this.totalValue,
  });
}
