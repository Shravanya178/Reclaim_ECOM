import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart.dart';
import '../models/cart_item.dart';

/// Repository for cart operations
class CartRepository {
  final SupabaseClient _supabase;

  CartRepository(this._supabase);

  /// Get user's cart with items
  Future<Cart?> getUserCart(String userId) async {
    try {
      // Get cart
      final cartResponse = await _supabase
          .from('carts')
          .select()
          .eq('user_id', userId)
          .single();

      final cartId = cartResponse['id'] as String;

      // Get cart items with material details
      final itemsResponse = await _supabase
          .from('cart_items')
          .select('''
            *,
            material:materials(
              id,
              name,
              type,
              condition,
              image_url,
              base_price,
              stock_quantity
            )
          ''')
          .eq('cart_id', cartId);

      final items = (itemsResponse as List).map((item) {
        final material = item['material'];
        return CartItem(
          id: item['id'],
          cartId: cartId,
          materialId: material['id'],
          materialName: material['name'],
          materialType: material['type'],
          materialImageUrl: material['image_url'],
          quantity: item['quantity'],
          unitPrice: (material['base_price'] as num).toDouble(),
          condition: material['condition'],
          stockAvailable: material['stock_quantity'] as int,
          addedAt: DateTime.parse(item['added_at']),
        );
      }).toList();

      return Cart(
        id: cartId,
        userId: userId,
        items: items,
        createdAt: DateTime.parse(cartResponse['created_at']),
        updatedAt: DateTime.parse(cartResponse['updated_at']),
      );
    } catch (e) {
      print('Error fetching cart: $e');
      return null;
    }
  }

  /// Add item to cart
  Future<bool> addToCart({
    required String cartId,
    required String materialId,
    int quantity = 1,
  }) async {
    try {
      // Check if item already exists
      final existing = await _supabase
          .from('cart_items')
          .select()
          .eq('cart_id', cartId)
          .eq('material_id', materialId)
          .maybeSingle();

      if (existing != null) {
        // Update quantity
        await _supabase
            .from('cart_items')
            .update({
              'quantity': existing['quantity'] + quantity,
            })
            .eq('id', existing['id']);
      } else {
        // Insert new item
        await _supabase.from('cart_items').insert({
          'cart_id': cartId,
          'material_id': materialId,
          'quantity': quantity,
        });
      }

      // Update cart timestamp
      await _supabase
          .from('carts')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', cartId);

      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        return await removeCartItem(cartItemId);
      }

      await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);

      return true;
    } catch (e) {
      print('Error updating cart item: $e');
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeCartItem(String cartItemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', cartItemId);
      return true;
    } catch (e) {
      print('Error removing cart item: $e');
      return false;
    }
  }

  /// Clear entire cart
  Future<bool> clearCart(String cartId) async {
    try {
      await _supabase.from('cart_items').delete().eq('cart_id', cartId);
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  /// Check if material is in cart
  Future<bool> isInCart({
    required String cartId,
    required String materialId,
  }) async {
    try {
      final result = await _supabase
          .from('cart_items')
          .select()
          .eq('cart_id', cartId)
          .eq('material_id', materialId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount(String cartId) async {
    try {
      final result = await _supabase
          .from('cart_items')
          .select('quantity')
          .eq('cart_id', cartId);

      return (result as List).fold<int>(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );
    } catch (e) {
      return 0;
    }
  }
}
