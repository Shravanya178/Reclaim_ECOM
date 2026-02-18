import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Product model - extends Material model for e-commerce
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String type,
    required String quantity,
    required String condition,
    required String location,
    String? imageUrl,
    String? notes,
    required String status,
    required double carbonSaved,
    String? campusId,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // E-commerce specific fields
    required double basePrice,
    required int stockQuantity,
    required bool isListedForSale,
    int? irsScore, // Innovation Reuse Score
    String? lifecycleState,
    double? confidence,
    
    // Additional computed fields
    List<String>? tags,
    double? rating,
    int? reviewCount,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

const Product._();

extension ProductHelpers on Product {
  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0;

  /// Check if product is out of stock
  bool get isOutOfStock => stockQuantity <= 0;

  /// Check if stock is low (less than 5 units)
  bool get isLowStock => stockQuantity > 0 && stockQuantity < 5;

  /// Get display price formatted
  String get displayPrice => '₹${basePrice.toStringAsFixed(2)}';

  /// Check if available for purchase
  bool get isAvailable => isListedForSale && isInStock;

  /// Get condition badge color
  String get conditionColor {
    switch (condition.toLowerCase()) {
      case 'excellent':
        return '#4CAF50';
      case 'good':
        return '#8BC34A';
      case 'fair':
        return '#FFC107';
      case 'poor':
        return '#FF5722';
      default:
        return '#9E9E9E';
    }
  }

  /// Get type icon
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'electronic':
        return '⚡';
      case 'metal':
        return '🔩';
      case 'plastic':
        return '🔄';
      case 'glass':
        return '🥃';
      case 'wood':
        return '🪵';
      case 'chemical':
        return '🧪';
      default:
        return '📦';
    }
  }

  /// Calculate discount percentage if any
  double? get discountPercentage => null; // Can be extended for sales

  /// Get original price if discounted
  double? get originalPrice => null; // Can be extended for sales
}

/// Product filter options
@freezed
class ProductFilters with _$ProductFilters {
  const factory ProductFilters({
    List<String>? types,
    List<String>? conditions,
    double? minPrice,
    double? maxPrice,
    String? campusId,
    bool? inStockOnly,
    String? searchQuery,
    ProductSortOption? sortBy,
  }) = _ProductFilters;

  factory ProductFilters.fromJson(Map<String, dynamic> json) =>
      _$ProductFiltersFromJson(json);
}

/// Sort options for products
enum ProductSortOption {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
  nameAtoZ,
  nameZtoA,
  mostPopular,
  highestRated,
  carbonSaved,
}

extension ProductSortOptionExt on ProductSortOption {
  String get displayName {
    switch (this) {
      case ProductSortOption.newest:
        return 'Newest First';
      case ProductSortOption.oldest:
        return 'Oldest First';
      case ProductSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighToLow:
        return 'Price: High to Low';
      case ProductSortOption.nameAtoZ:
        return 'Name: A to Z';
      case ProductSortOption.nameZtoA:
        return 'Name: Z to A';
      case ProductSortOption.mostPopular:
        return 'Most Popular';
      case ProductSortOption.highestRated:
        return 'Highest Rated';
      case ProductSortOption.carbonSaved:
        return 'Carbon Impact';
    }
  }
}
