import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cart.dart';

/// Repository for order operations
class OrderRepository {
  final SupabaseClient _supabase;

  OrderRepository(this._supabase);

  /// Create order from cart
  Future<Order?> createOrder({
    required Cart cart,
    required ShippingAddress shippingAddress,
    String? notes,
  }) async {
    try {
      // Generate order number (done by database function)
      final orderResponse = await _supabase.from('orders').insert({
        'order_number': 'temp', // Will be replaced by trigger
        'user_id': cart.userId,
        'total_amount': cart.total,
        'subtotal': cart.subtotal,
        'tax_amount': cart.taxAmount,
        'shipping_amount': cart.shippingAmount,
        'discount_amount': 0,
        'status': 'pending',
        'payment_status': 'pending',
        'shipping_address_line1': shippingAddress.addressLine1,
        'shipping_address_line2': shippingAddress.addressLine2,
        'shipping_city': shippingAddress.city,
        'shipping_state': shippingAddress.state,
        'shipping_postal_code': shippingAddress.postalCode,
        'shipping_country': shippingAddress.country,
        'shipping_phone': shippingAddress.phone,
        'notes': notes,
      }).select().single();

      final orderId = orderResponse['id'] as String;

      // Create order items
      final orderItems = cart.items.map((item) {
        return {
          'order_id': orderId,
          'material_id': item.materialId,
          'material_name': item.materialName,
          'material_type': item.materialType,
          'material_image_url': item.materialImageUrl,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      // Fetch the complete order
      return await getOrder(orderId);
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Get order by ID
  Future<Order?> getOrder(String orderId) async {
    try {
      final orderResponse = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      final itemsResponse = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      final items = (itemsResponse as List).map((item) {
        return OrderItem(
          id: item['id'],
          orderId: orderId,
          materialId: item['material_id'],
          materialName: item['material_name'],
          materialType: item['material_type'],
          materialImageUrl: item['material_image_url'],
          quantity: item['quantity'],
          unitPrice: (item['unit_price'] as num).toDouble(),
          subtotal: (item['subtotal'] as num).toDouble(),
          createdAt: DateTime.parse(item['created_at']),
        );
      }).toList();

      return _orderFromJson(orderResponse, items);
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  /// Get user's orders
  Future<List<Order>> getUserOrders(String userId, {int limit = 50}) async {
    try {
      final ordersResponse = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final orders = <Order>[];
      for (var orderData in ordersResponse as List) {
        final orderId = orderData['id'] as String;
        
        final itemsResponse = await _supabase
            .from('order_items')
            .select()
            .eq('order_id', orderId);

        final items = (itemsResponse as List).map((item) {
          return OrderItem(
            id: item['id'],
            orderId: orderId,
            materialId: item['material_id'],
            materialName: item['material_name'],
            materialType: item['material_type'],
            materialImageUrl: item['material_image_url'],
            quantity: item['quantity'],
            unitPrice: (item['unit_price'] as num).toDouble(),
            subtotal: (item['subtotal'] as num).toDouble(),
            createdAt: DateTime.parse(item['created_at']),
          );
        }).toList();

        orders.add(_orderFromJson(orderData, items));
      }

      return orders;
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status.name})
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(
    String orderId,
    PaymentStatus status,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({'payment_status': status.name})
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _supabase.from('orders').update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancelled_reason': reason,
      }).eq('id', orderId);
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  /// Update tracking number
  Future<bool> updateTrackingNumber(
    String orderId,
    String trackingNumber,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({'tracking_number': trackingNumber})
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updating tracking number: $e');
      return false;
    }
  }

  /// Stream order updates
  Stream<Order?> streamOrder(String orderId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) {
          if (data.isEmpty) return null;
          return _orderFromJson(data.first, []);
        });
  }

  /// Helper to convert JSON to Order
  Order _orderFromJson(Map<String, dynamic> json, List<OrderItem> items) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      userId: json['user_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      shippingAmount: (json['shipping_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      shippingAddress: ShippingAddress(
        addressLine1: json['shipping_address_line1'],
        addressLine2: json['shipping_address_line2'],
        city: json['shipping_city'],
        state: json['shipping_state'],
        postalCode: json['shipping_postal_code'],
        country: json['shipping_country'],
        phone: json['shipping_phone'],
      ),
      trackingNumber: json['tracking_number'],
      notes: json['notes'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancelledReason: json['cancelled_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: items.isEmpty ? null : items,
    );
  }
}
