import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reclaim/features/ecommerce/providers/cart_provider.dart';
import 'package:reclaim/features/ecommerce/models/cart.dart';

/// Shopping Cart Screen
///
/// Displays cart items with quantity controls and checkout button
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(userCartProvider);

    return cartAsync.when(
      data: (cart) => _buildCartContent(context, ref, cart),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, Cart? cart) {
    final hasItems = cart != null && cart.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (hasItems)
            TextButton(
              onPressed: () async {
                final clearCart = ref.read(clearCartProvider);
                await clearCart(cart.id);
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: hasItems
          ? _buildCartItems(context, ref, cart, isDesktop)
          : _buildEmptyCart(context, isDesktop),
      bottomNavigationBar:
          hasItems ? _buildCheckoutBar(context, ref, cart, isDesktop) : null,
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool isDesktop) {
    final iconSize = isDesktop ? 100.0 : 80.0;
    final titleSize = isDesktop ? 20.0 : 18.0;
    final subtitleSize = isDesktop ? 14.0 : 12.0;
    final buttonPadding = isDesktop ? 24.0 : 16.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: iconSize,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: buttonPadding, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(
      BuildContext context, WidgetRef ref, Cart cart, bool isDesktop) {
    final padding = isDesktop ? 24.0 : 16.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 700),
        child: ListView.separated(
          padding: EdgeInsets.all(padding),
          itemCount: cart.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return _buildCartItemCard(context, ref, item, isDesktop);
          },
        ),
      ),
    );
  }

  Widget _buildCartItemCard(
      BuildContext context, WidgetRef ref, item, bool isDesktop) {
    final imageSize = isDesktop ? 80.0 : 60.0;
    final titleSize = isDesktop ? 16.0 : 14.0;
    final subtitleSize = isDesktop ? 12.0 : 11.0;
    final priceSize = isDesktop ? 16.0 : 14.0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 12.0 : 8.0),
        child: Row(
          children: [
            // Product Image
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: item.materialImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.materialImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.materialImageUrl == null
                  ? Icon(
                      Icons.inventory_2_outlined,
                      size: imageSize * 0.5,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
            SizedBox(width: isDesktop ? 12.0 : 8.0),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.materialName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.condition,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: priceSize,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      _buildQuantityControls(
                          context, ref, item, isDesktop),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
              ),
              onPressed: () async {
                final removeFromCart = ref.read(removeFromCartProvider);
                await removeFromCart(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
      BuildContext context, WidgetRef ref, item, bool isDesktop) {
    final iconSize = isDesktop ? 16.0 : 14.0;
    final textSize = isDesktop ? 14.0 : 12.0;
    final padding = isDesktop ? 4.0 : 2.0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            iconSize: iconSize,
            padding: EdgeInsets.all(padding),
            constraints: const BoxConstraints(),
            onPressed: item.quantity > 1
                ? () async {
                    final updateCartQuantity =
                        ref.read(updateCartQuantityProvider);
                    await updateCartQuantity(
                        item.id, item.quantity - 1);
                  }
                : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8.0 : 6.0),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textSize,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: iconSize,
            padding: EdgeInsets.all(padding),
            constraints: const BoxConstraints(),
            onPressed: item.quantity < item.stockAvailable
                ? () async {
                    final updateCartQuantity =
                        ref.read(updateCartQuantityProvider);
                    await updateCartQuantity(
                        item.id, item.quantity + 1);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(
      BuildContext context, WidgetRef ref, Cart cart, bool isDesktop) {
    final padding = isDesktop ? 16.0 : 12.0;
    final smallTextSize = isDesktop ? 14.0 : 12.0;
    final largeTextSize = isDesktop ? 18.0 : 16.0;
    final priceSize = isDesktop ? 20.0 : 18.0;
    final buttonHeight = isDesktop ? 48.0 : 44.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: smallTextSize),
                ),
                Text(
                  '₹${cart.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: smallTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (18%):',
                  style: TextStyle(fontSize: smallTextSize),
                ),
                Text(
                  '₹${cart.taxAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: smallTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipping:',
                  style: TextStyle(fontSize: smallTextSize),
                ),
                Text(
                  cart.shippingAmount == 0
                      ? 'FREE'
                      : '₹${cart.shippingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: smallTextSize,
                    fontWeight: FontWeight.w500,
                    color: cart.shippingAmount == 0 ? Colors.green : null,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: largeTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${cart.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: priceSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to checkout
                  // context.go('/checkout');
                },
                child: Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: smallTextSize + 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
