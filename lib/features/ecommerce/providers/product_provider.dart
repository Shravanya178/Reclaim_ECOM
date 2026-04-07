import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import 'cart_provider.dart';

/// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ProductRepository(supabase);
});

/// Product filters state provider
final productFiltersProvider = StateProvider<ProductFilters>((ref) {
  return const ProductFilters();
});

/// Products list provider with filters
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final filters = ref.watch(productFiltersProvider);
  
  return await repository.getProducts(filters: filters, limit: 50);
});

/// Single product provider
final productProvider = FutureProvider.autoDispose.family<Product?, String>((ref, productId) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProduct(productId);
});

/// Featured products provider
final featuredProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getFeaturedProducts(limit: 10);
});

/// Product search provider
final productSearchProvider = FutureProvider.autoDispose.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final repository = ref.watch(productRepositoryProvider);
  return await repository.searchProducts(query);
});

/// Product types provider
final productTypesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductTypes();
});

/// Product statistics provider
final productStatsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductStats();
});
