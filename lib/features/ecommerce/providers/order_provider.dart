import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../repositories/order_repository.dart';
import 'cart_provider.dart';

/// Order repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return OrderRepository(supabase);
});

/// User orders provider
final userOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user == null) return [];
  
  return await repository.getUserOrders(user.id);
});

/// Single order provider
final orderProvider = FutureProvider.autoDispose.family<Order?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getOrder(orderId);
});

/// Order stream provider (realtime updates)
final orderStreamProvider = StreamProvider.autoDispose.family<Order?, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.streamOrder(orderId);
});

/// Create order action
final createOrderProvider = Provider<Future<Order?> Function(ShippingAddress address, String? notes)>((ref) {
  return (ShippingAddress address, String? notes) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    final cartRepository = ref.read(cartRepositoryProvider);
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) return null;
    
    final cart = await cartRepository.getUserCart(user.id);
    if (cart == null || cart.isEmpty) return null;
    
    final order = await orderRepository.createOrder(
      cart: cart,
      shippingAddress: address,
      notes: notes,
    );
    
    // Clear cart after successful order
    if (order != null) {
      await cartRepository.clearCart(cart.id);
    }
    
    return order;
  };
});

/// Cancel order action
final cancelOrderProvider = Provider<Future<bool> Function(String orderId, String reason)>((ref) {
  return (String orderId, String reason) async {
    final repository = ref.read(orderRepositoryProvider);
    return await repository.cancelOrder(orderId, reason);
  };
});
