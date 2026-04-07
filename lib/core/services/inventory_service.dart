import 'package:supabase_flutter/supabase_flutter.dart';

/// Inventory management service
class InventoryService {
  final SupabaseClient _supabase;

  InventoryService(this._supabase);

  /// Check if material is available in requested quantity
  Future<bool> checkAvailability(String materialId, int quantity) async {
    try {
      final result = await _supabase
          .from('materials')
          .select('stock_quantity')
          .eq('id', materialId)
          .single();

      final stockQuantity = result['stock_quantity'] as int;
      return stockQuantity >= quantity;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  /// Reserve stock for an order (reduce available quantity)
  Future<bool> reserveStock(String materialId, int quantity) async {
    try {
      // Get current stock
      final result = await _supabase
          .from('materials')
          .select('stock_quantity')
          .eq('id', materialId)
          .single();

      final currentStock = result['stock_quantity'] as int;

      if (currentStock < quantity) {
        return false; // Insufficient stock
      }

      // Update stock
      await _supabase
          .from('materials')
          .update({'stock_quantity': currentStock - quantity})
          .eq('id', materialId);

      return true;
    } catch (e) {
      print('Error reserving stock: $e');
      return false;
    }
  }

  /// Release reserved stock (add back to available quantity)
  Future<bool> releaseStock(String materialId, int quantity) async {
    try {
      final result = await _supabase
          .from('materials')
          .select('stock_quantity')
          .eq('id', materialId)
          .single();

      final currentStock = result['stock_quantity'] as int;

      await _supabase
          .from('materials')
          .update({'stock_quantity': currentStock + quantity})
          .eq('id', materialId);

      return true;
    } catch (e) {
      print('Error releasing stock: $e');
      return false;
    }
  }

  /// Update stock quantity directly
  Future<bool> updateStock(String materialId, int newQuantity) async {
    try {
      await _supabase
          .from('materials')
          .update({'stock_quantity': newQuantity})
          .eq('id', materialId);

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  /// Get inventory report for admin
  Future<InventoryReport> getInventoryReport() async {
    try {
      // Get all listed materials
      final materials = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true);

      final totalProducts = materials.length;
      var totalValue = 0.0;
      var lowStockCount = 0;
      var outOfStockCount = 0;

      for (var material in materials) {
        final stock = material['stock_quantity'] as int;
        final price = (material['base_price'] as num?)?.toDouble() ?? 0.0;
        
        totalValue += stock * price;
        
        if (stock == 0) {
          outOfStockCount++;
        } else if (stock < 5) {
          lowStockCount++;
        }
      }

      return InventoryReport(
        totalProducts: totalProducts,
        totalValue: totalValue,
        lowStockCount: lowStockCount,
        outOfStockCount: outOfStockCount,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error generating inventory report: $e');
      return InventoryReport(
        totalProducts: 0,
        totalValue: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Get low stock items
  Future<List<Map<String, dynamic>>> getLowStockItems({int threshold = 5}) async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true)
          .lt('stock_quantity', threshold)
          .gt('stock_quantity', 0)
          .order('stock_quantity', ascending: true);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching low stock items: $e');
      return [];
    }
  }

  /// Get out of stock items
  Future<List<Map<String, dynamic>>> getOutOfStockItems() async {
    try {
      final result = await _supabase
          .from('materials')
          .select()
          .eq('is_listed_for_sale', true)
          .eq('stock_quantity', 0);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching out of stock items: $e');
      return [];
    }
  }

  /// Bulk update stock
  Future<bool> bulkUpdateStock(List<StockUpdate> updates) async {
    try {
      for (var update in updates) {
        await updateStock(update.materialId, update.newQuantity);
      }
      return true;
    } catch (e) {
      print('Error bulk updating stock: $e');
      return false;
    }
  }

  /// Mark material as out of stock
  Future<bool> markOutOfStock(String materialId) async {
    return await updateStock(materialId, 0);
  }

  /// Restock material
  Future<bool> restockMaterial(String materialId, int quantity) async {
    try {
      final result = await _supabase
          .from('materials')
          .select('stock_quantity')
          .eq('id', materialId)
          .single();

      final currentStock = result['stock_quantity'] as int;

      await _supabase
          .from('materials')
          .update({'stock_quantity': currentStock + quantity})
          .eq('id', materialId);

      return true;
    } catch (e) {
      print('Error restocking material: $e');
      return false;
    }
  }
}

/// Inventory report model
class InventoryReport {
  final int totalProducts;
  final double totalValue;
  final int lowStockCount;
  final int outOfStockCount;
  final DateTime lastUpdated;

  InventoryReport({
    required this.totalProducts,
    required this.totalValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.lastUpdated,
  });
}

/// Stock update model for bulk operations
class StockUpdate {
  final String materialId;
  final int newQuantity;

  StockUpdate({
    required this.materialId,
    required this.newQuantity,
  });
}
