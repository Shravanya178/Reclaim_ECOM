import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:reclaim/features/ecommerce/providers/order_provider.dart';

/// Order History Screen - Lists all user orders
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: ListView.separated(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                itemCount: orders.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading orders'),
              SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(userOrdersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Start shopping to place your first order',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to order detail
          Navigator.pushNamed(context, '/order/${order.id}');
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.orderNumber}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    dateFormat.format(order.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${order.items?.length ?? 0} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (order.canBeCancelled)
                    OutlinedButton(
                      onPressed: () => _showCancelDialog(context, order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(status) {
    Color color;
    String text = status.name.toUpperCase();

    switch (status.name) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'cancelled':
      case 'refunded':
        color = Colors.red;
        break;
      case 'processing':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel order
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
