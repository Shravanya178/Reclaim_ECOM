/// Product model - extends Material model for e-commerce
class Product {
  final String id;
  final String name;
  final String type;
  final String quantity;
  final String condition;
  final String location;
  final String? imageUrl;
  final String? notes;
  final String status;
  final double carbonSaved;
  final String? campusId;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // E-commerce specific fields
  final double basePrice;
  final int stockQuantity;
  final bool isListedForSale;
  final int? irsScore; // Innovation Reuse Score
  final String? lifecycleState;
  final double? confidence;

  // Additional computed fields
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.condition,
    required this.location,
    this.imageUrl,
    this.notes,
    required this.status,
    required this.carbonSaved,
    this.campusId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.basePrice,
    required this.stockQuantity,
    required this.isListedForSale,
    this.irsScore,
    this.lifecycleState,
    this.confidence,
    this.tags,
    this.rating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as String,
      condition: json['condition'] as String,
      location: json['location'] as String,
      imageUrl: json['image_url'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      carbonSaved: (json['carbon_saved'] as num).toDouble(),
      campusId: json['campus_id'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      basePrice: (json['base_price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      isListedForSale: json['is_listed_for_sale'] as bool,
      irsScore: json['irs_score'] as int?,
      lifecycleState: json['lifecycle_state'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'condition': condition,
      'location': location,
      'image_url': imageUrl,
      'notes': notes,
      'status': status,
      'carbon_saved': carbonSaved,
      'campus_id': campusId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'base_price': basePrice,
      'stock_quantity': stockQuantity,
      'is_listed_for_sale': isListedForSale,
      'irs_score': irsScore,
      'lifecycle_state': lifecycleState,
      'confidence': confidence,
      'tags': tags,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

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
class ProductFilters {
  final List<String>? types;
  final List<String>? conditions;
  final double? minPrice;
  final double? maxPrice;
  final String? campusId;
  final bool? inStockOnly;
  final String? searchQuery;
  final ProductSortOption? sortBy;

  const ProductFilters({
    this.types,
    this.conditions,
    this.minPrice,
    this.maxPrice,
    this.campusId,
    this.inStockOnly,
    this.searchQuery,
    this.sortBy,
  });

  factory ProductFilters.fromJson(Map<String, dynamic> json) {
    return ProductFilters(
      types: (json['types'] as List<dynamic>?)?.cast<String>(),
      conditions: (json['conditions'] as List<dynamic>?)?.cast<String>(),
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      campusId: json['campus_id'] as String?,
      inStockOnly: json['in_stock_only'] as bool?,
      searchQuery: json['search_query'] as String?,
      sortBy: json['sort_by'] != null
          ? ProductSortOption.values.byName(json['sort_by'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'types': types,
      'conditions': conditions,
      'min_price': minPrice,
      'max_price': maxPrice,
      'campus_id': campusId,
      'in_stock_only': inStockOnly,
      'search_query': searchQuery,
      'sort_by': sortBy?.name,
    };
  }
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
