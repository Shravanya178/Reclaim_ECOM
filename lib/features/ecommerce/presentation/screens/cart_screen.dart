import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/ecommerce/providers/local_cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    final cartItems = ref.watch(localCartProvider);
    final cartCount = ref.watch(localCartCountProvider);

    return ResponsiveScaffold(
      currentRoute: '/cart',
      cartItemCount: cartCount,
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.go('/shop')),
              title: Text('Cart ($cartCount)', style: const TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      body: cartItems.isEmpty ? _buildEmpty(context, isMobile) : _buildCart(context, ref, cartItems, isMobile),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isMobile) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 120, height: 120,
        decoration: BoxDecoration(color: AppTheme.primarySurface, shape: BoxShape.circle),
        child: const Icon(Icons.shopping_bag_outlined, size: 56, color: AppTheme.primaryLight)),
      const SizedBox(height: 24),
      const Text('Your cart is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      const SizedBox(height: 8),
      Text('Explore sustainable materials and add them to your cart.',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500), textAlign: TextAlign.center),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: () => context.go('/shop'),
        icon: const Icon(Icons.storefront_outlined, size: 18),
        label: const Text('Browse Shop', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ]),
  );

  Widget _buildCart(BuildContext context, WidgetRef ref, List<LocalCartItem> items, bool isMobile) {
    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(child: Column(children: [
      if (!isMobile) _buildPageHeader(context, items.length),
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(
          padding: isMobile
              ? const EdgeInsets.all(14)
              : const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: isMobile
              ? _buildMobileLayout(context, ref, items)
              : _buildDesktopLayout(context, ref, items),
        ),
      )),
      if (!isMobile) const WebFooter(),
    ]));
  }

  Widget _buildPageHeader(BuildContext context, int count) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 56),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.home_outlined, color: Colors.white60, size: 13),
        const SizedBox(width: 6),
        Text('Shop', style: TextStyle(color: Colors.white60, fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.white60)),
        Icon(Icons.chevron_right, color: Colors.white38, size: 15),
        const Text('Cart', style: TextStyle(color: Colors.white, fontSize: 13)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        const Text('Shopping Cart', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
          child: Text('$count item${count == 1 ? '' : 's'}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    ]),
  );

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, List<LocalCartItem> items) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 3, child: _buildItemList(context, ref, items, desktop: true)),
      const SizedBox(width: 28),
      SizedBox(width: 340, child: _buildSummary(context, ref, items, desktop: true)),
    ],
  );

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, List<LocalCartItem> items) => Column(children: [
    _buildItemList(context, ref, items, desktop: false),
    const SizedBox(height: 20),
    _buildSummary(context, ref, items, desktop: false),
  ]);

  // ─── Item List ─────────────────────────────────────────────────────────────
  Widget _buildItemList(BuildContext context, WidgetRef ref, List<LocalCartItem> items, {required bool desktop}) => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Cart Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      TextButton.icon(
        onPressed: () { ref.read(localCartProvider.notifier).clear(); },
        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
        label: const Text('Clear All'),
        style: TextButton.styleFrom(foregroundColor: Colors.red.shade400)),
    ]),
    const SizedBox(height: 14),
    ...items.map((item) => _CartItemTile(item: item, desktop: desktop)),
  ]);

  // ─── Order Summary ─────────────────────────────────────────────────────────
  Widget _buildSummary(BuildContext context, WidgetRef ref, List<LocalCartItem> items, {required bool desktop}) {
    final total = items.fold(0.0, (s, i) => s + i.price * i.quantity);
    final itemCount = items.fold(0, (s, i) => s + i.quantity);
    final co2Saved = items.fold(0.0, (s, i) => s + i.co2 * i.quantity);
    const delivery = 49.0;
    final grandTotal = total + delivery;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Order Summary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 20),
        _summaryRow('Subtotal ($itemCount item${itemCount == 1 ? '' : 's'})', 'Rs.${total.toStringAsFixed(0)}'),
        const SizedBox(height: 10),
        _summaryRow('Delivery', 'Rs.${delivery.toStringAsFixed(0)}'),
        const SizedBox(height: 10),
        _summaryRow('Discount', '−Rs.0', valueColor: AppTheme.primaryGreen),
        const Divider(height: 28, color: Color(0xFFE5EFE8)),
        _summaryRow('Total', 'Rs.${grandTotal.toStringAsFixed(0)}', bold: true, size: 17),
        const SizedBox(height: 20),
        // Eco impact box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA8D5B5))),
          child: Row(children: [
            const Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 28),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Eco Impact', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryDark)),
              const SizedBox(height: 2),
              Text('Saving ${co2Saved.toStringAsFixed(1)} kg CO₂ from landfill',
                style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () => context.go('/checkout'),
          icon: const Icon(Icons.payment_outlined, size: 18),
          label: Text('Proceed to Checkout  •  Rs.${grandTotal.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4, shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4)),
        )),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () => context.go('/shop'),
          icon: const Icon(Icons.storefront_outlined, size: 16),
          label: const Text('Continue Shopping'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryGreen,
            side: const BorderSide(color: AppTheme.primaryGreen),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Text('Secure Checkout • SSL Encrypted', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }

  Widget _summaryRow(String l, String v, {bool bold = false, Color? valueColor, double size = 14}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(fontSize: size, color: bold ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(v, style: TextStyle(fontSize: size, color: valueColor ?? (bold ? AppTheme.textPrimary : AppTheme.textPrimary), fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    ],
  );
}

// ─── Cart Item Tile ───────────────────────────────────────────────────────────
class _CartItemTile extends ConsumerStatefulWidget {
  final LocalCartItem item;
  final bool desktop;
  const _CartItemTile({required this.item, required this.desktop});
  @override
  ConsumerState<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends ConsumerState<_CartItemTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit:  (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _hovered ? AppTheme.primaryLight : const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(
          color: _hovered ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
          blurRadius: _hovered ? 20 : 8, offset: const Offset(0, 3))]),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: widget.desktop ? 100 : 80, height: widget.desktop ? 100 : 80,
            child: Image.network(widget.item.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppTheme.primarySurface,
                child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.primaryLight))))),
        const SizedBox(width: 14),
        // Details
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.location_pin, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 3),
            Expanded(child: Text(widget.item.lab, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(4)),
            child: Text(widget.item.condition, style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Rs.${(widget.item.price * widget.item.quantity).toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
            // Qty stepper
            Container(
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4E6DA)),
                borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _qtyBtn(Icons.remove_rounded, () {
                  final n = widget.item.quantity - 1;
                  if (n <= 0) ref.read(localCartProvider.notifier).remove(widget.item.id);
                  else ref.read(localCartProvider.notifier).updateQty(widget.item.id, n);
                }),
                Container(width: 36, alignment: Alignment.center,
                  child: Text('${widget.item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                _qtyBtn(Icons.add_rounded, () {
                  ref.read(localCartProvider.notifier).updateQty(widget.item.id, widget.item.quantity + 1);
                }),
              ]),
            ),
          ]),
        ])),
        // Remove button
        InkWell(
          onTap: () => ref.read(localCartProvider.notifier).remove(widget.item.id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.close_rounded, size: 18, color: Colors.red.shade300))),
      ]),
    ),
  );

  Widget _qtyBtn(IconData ic, VoidCallback fn) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: fn,
      borderRadius: BorderRadius.circular(6),
      child: Container(width: 30, height: 34, alignment: Alignment.center,
        child: Icon(ic, size: 16, color: AppTheme.primaryGreen))),
  );
}
