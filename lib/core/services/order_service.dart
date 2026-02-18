import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ecommerce/models/order.dart';
import '../../features/ecommerce/repositories/order_repository.dart';

/// Order management service
class OrderService {
  final SupabaseClient _supabase;
  final OrderRepository _orderRepository;

  OrderService(this._supabase, this._orderRepository);

  /// Create order from cart
  Future<Order?> createOrder({
    required String cartId,
    required String userId,
    required ShippingAddress shippingAddress,
    String? notes,
  }) async {
    // Implementation would use cart repository and order repository
    // This is handled by OrderRepository.createOrder
    return null;
  }

  /// Update order status with notifications
  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);

      // Send notification to user
      await _sendOrderNotification(orderId, status);

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Get user orders
  Future<List<Order>> getUserOrders(String userId) async {
    return await _orderRepository.getUserOrders(userId);
  }

  /// Get order details
  Future<Order?> getOrderDetails(String orderId) async {
    return await _orderRepository.getOrder(orderId);
  }

  /// Stream order status updates
  Stream<Order?> trackOrder(String orderId) {
    return _orderRepository.streamOrder(orderId);
  }

  /// Cancel order with reason
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _orderRepository.cancelOrder(orderId, reason);

      // Restore inventory
      final order = await _orderRepository.getOrder(orderId);
      if (order != null && order.items != null) {
        for (var item in order.items!) {
          if (item.materialId != null) {
            // Restore stock would be handled by inventory service
          }
        }
      }

      // Send cancellation notification
      await _sendOrderNotification(orderId, OrderStatus.cancelled);

      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  /// Process order shipment
  Future<bool> shipOrder(String orderId, String trackingNumber) async {
    try {
      await _orderRepository.updateTrackingNumber(orderId, trackingNumber);
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.shipped);

      // Send shipment notification
      await _sendOrderNotification(orderId, OrderStatus.shipped);

      return true;
    } catch (e) {
      print('Error shipping order: $e');
      return false;
    }
  }

  /// Mark order as delivered
  Future<bool> deliverOrder(String orderId) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, OrderStatus.delivered);

      // Send delivery notification
      await _sendOrderNotification(orderId, OrderStatus.delivered);

      // Request feedback
      await _requestFeedback(orderId);

      return true;
    } catch (e) {
      print('Error delivering order: $e');
      return false;
    }
  }

  /// Get orders by status (for admin)
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final result = await _supabase
          .from('orders')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);

      // Convert to Order objects
      final orders = <Order>[];
      for (var orderData in result as List) {
        final order = await _orderRepository.getOrder(orderData['id']);
        if (order != null) orders.add(order);
      }

      return orders;
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }

  /// Get pending orders count
  Future<int> getPendingOrdersCount() async {
    try {
      final result = await _supabase
          .from('orders')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'pending');

      return result.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Send order notification
  Future<void> _sendOrderNotification(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      final order = await _orderRepository.getOrder(orderId);
      if (order == null) return;

      String title;
      String message;

      switch (status) {
        case OrderStatus.confirmed:
          title = 'Order Confirmed';
          message = 'Your order ${order.orderNumber} has been confirmed';
          break;
        case OrderStatus.processing:
          title = 'Order Processing';
          message = 'Your order ${order.orderNumber} is being processed';
          break;
        case OrderStatus.shipped:
          title = 'Order Shipped';
          message = 'Your order ${order.orderNumber} has been shipped';
          break;
        case OrderStatus.delivered:
          title = 'Order Delivered';
          message = 'Your order ${order.orderNumber} has been delivered';
          break;
        case OrderStatus.cancelled:
          title = 'Order Cancelled';
          message = 'Your order ${order.orderNumber} has been cancelled';
          break;
        default:
          return;
      }

      await _supabase.from('notifications').insert({
        'user_id': order.userId,
        'type': 'system',
        'title': title,
        'message': message,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Request feedback from user
  Future<void> _requestFeedback(String orderId) async {
    try {
      final order = await _orderRepository.getOrder(orderId);
      if (order == null) return;

      await _supabase.from('notifications').insert({
        'user_id': order.userId,
        'type': 'system',
        'title': 'Rate Your Order',
        'message':
            'How was your experience with order ${order.orderNumber}? Please share your feedback!',
      });
    } catch (e) {
      print('Error requesting feedback: $e');
    }
  }
}
