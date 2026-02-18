import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';

/// Order Detail Screen - Shows complete order information
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        elevation: 0,
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusHeader(context, order),
                _buildOrderInfo(context, order),
                _buildOrderItems(context, order),
                _buildShippingAddress(context, order),
                _buildPriceSummary(context, order),
                if (order.trackingNumber != null) _buildTrackingInfo(context, order),
                if (order.canBeCancelled) _buildCancelButton(context, ref, order.id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Order order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      color: _getStatusColor(order.status).withOpacity(0.1),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(order.status),
            size: 64.sp,
            color: _getStatusColor(order.status),
          ),
          SizedBox(height: 12.h),
          Text(
            order.statusText,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(order.status),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Order ${order.orderNumber}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Order Date', dateFormat.format(order.createdAt)),
          _buildInfoRow('Payment Status', order.paymentStatusText),
          if (order.notes != null) _buildInfoRow('Notes', order.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, Order order) {
    if (order.items == null || order.items!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Order Items',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: order.items!.length,
          separatorBuilder: (context, index) => Divider(height: 24.h),
          itemBuilder: (context, index) {
            final item = order.items![index];
            return Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: item.materialImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(item.materialImageUrl!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.inventory_2, size: 30.sp, color: Colors.grey[400]),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.materialName,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.materialType,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildShippingAddress(BuildContext context, Order order) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.shippingAddress.addressLine1),
                if (order.shippingAddress.addressLine2 != null)
                  Text(order.shippingAddress.addressLine2!),
                Text('${order.shippingAddress.city}, ${order.shippingAddress.state}'),
                Text('${order.shippingAddress.postalCode}, ${order.shippingAddress.country}'),
                if (order.shippingAddress.phone != null)
                  Text('Phone: ${order.shippingAddress.phone}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, Order order) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          _buildPriceRow('Subtotal', order.subtotal),
          _buildPriceRow('Tax', order.taxAmount),
          _buildPriceRow('Shipping', order.shippingAmount),
          if (order.discountAmount > 0) _buildPriceRow('Discount', -order.discountAmount),
          Divider(height: 24.h),
          _buildPriceRow('Total', order.totalAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(BuildContext context, Order order) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Information',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.blue),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tracking Number', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      Text(
                        order.trackingNumber!,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref, String orderId) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton(
          onPressed: () => _showCancelDialog(context, ref, orderId),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Cancel Order'),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String orderId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for cancellation:'),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final cancelOrder = ref.read(cancelOrderProvider);
              final success = await cancelOrder(orderId, reason);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Order cancelled successfully' : 'Failed to cancel order'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                
                if (success) {
                  ref.invalidate(orderProvider(orderId));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Colors.red;
      case OrderStatus.processing:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Icons.cancel;
      case OrderStatus.processing:
        return Icons.sync;
      default:
        return Icons.pending;
    }
  }
}
