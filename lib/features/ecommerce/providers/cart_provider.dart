import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart.dart';
import '../repositories/cart_repository.dart';

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Cart repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CartRepository(supabase);
});

/// Current user cart provider
final userCartProvider = StreamProvider.autoDispose<Cart?>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) {
    return Stream.value(null);
  }

  // Poll cart every 2 seconds to get updates
  return Stream.periodic(const Duration(seconds: 2), (_) async {
    return await repository.getUserCart(user.id);
  }).asyncMap((future) => future);
});

/// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(userCartProvider).value;
  return cart?.itemCount ?? 0;
});

/// Add to cart action
final addToCartProvider = Provider<Future<bool> Function(String materialId, int quantity)>((ref) {
  return (String materialId, int quantity) async {
    final repository = ref.read(cartRepositoryProvider);
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) return false;
    
    final cart = await repository.getUserCart(user.id);
    if (cart == null) return false;
    
    return await repository.addToCart(
      cartId: cart.id,
      materialId: materialId,
      quantity: quantity,
    );
  };
});

/// Remove from cart action
final removeFromCartProvider = Provider<Future<bool> Function(String cartItemId)>((ref) {
  return (String cartItemId) async {
    final repository = ref.read(cartRepositoryProvider);
    return await repository.removeCartItem(cartItemId);
  };
});

/// Update cart item quantity action
final updateCartQuantityProvider = Provider<Future<bool> Function(String cartItemId, int quantity)>((ref) {
  return (String cartItemId, int quantity) async {
    final repository = ref.read(cartRepositoryProvider);
    return await repository.updateCartItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  };
});

/// Clear cart action
final clearCartProvider = Provider<Future<bool> Function(String cartId)>((ref) {
  return (String cartId) async {
    final repository = ref.read(cartRepositoryProvider);
    return await repository.clearCart(cartId);
  };
});
