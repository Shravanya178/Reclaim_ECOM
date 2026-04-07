import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/ecommerce/providers/local_cart_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  static const _steps = ['Order Placed', 'Confirmed', 'Dispatched', 'Out for Delivery', 'Delivered'];

  String _erpLifecycleStatus(String status) {
    if (status == 'Delivered') return 'Completed';
    if (status == 'Cancelled') return 'Cancelled';
    return 'Processing';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    final cartCount = ref.watch(localCartCountProvider);
    return ResponsiveScaffold(
      currentRoute: '/orders',
      cartItemCount: cartCount,
      mobileAppBar: isMobile ? AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(orderId, style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/orders')),
      ) : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  Widget _desktop(BuildContext context) {
    const status = 'In Transit';
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(child: Column(children: [
      // header
      Container(width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 48), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextButton.icon(onPressed: (context as Element).findAncestorWidgetOfExactType<MaterialApp>() != null
              ? () {} : () {},
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              label: const Text('Back to Orders', style: TextStyle(color: Colors.white70))),
            const SizedBox(height: 8),
            Row(children: [
              Text(orderId, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(width: 16),
              _statusBadge(status),
            ]),
            const SizedBox(height: 4),
            const Text('Placed on 08 Jun 2025', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              'Order Status: ${_erpLifecycleStatus(status)}',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ]))))),
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Main
            Expanded(flex: 3, child: Column(children: [
              _trackingCard(),
              const SizedBox(height: 24),
              _itemsCard(),
            ])),
            const SizedBox(width: 28),
            // Side
            SizedBox(width: 320, child: Column(children: [
              _infoCard('Shipping Address', [
                _infoRow(Icons.person_outline,    'John Doe'),
                _infoRow(Icons.phone_outlined,    '+91 9800000000'),
                _infoRow(Icons.location_on_outlined, '102 Green Lane, Mumbai - 400001'),
              ]),
              const SizedBox(height: 16),
              _infoCard('Payment', [
                _infoRow(Icons.qr_code,      'UPI Payment'),
                _infoRow(Icons.receipt_long, 'Rs.449.00'),
              ]),
              const SizedBox(height: 16),
              _ecoCard(),
            ])),
          ]),
        ),
      )),
      const WebFooter(),
    ]));
  }

  Widget _trackingCard() => _card('Shipment Tracking', Icons.local_shipping_outlined, child: Column(children: [
    const SizedBox(height: 8),
    Row(children: List.generate(_steps.length * 2 - 1, (i) {
      if (i.isOdd) {
        final done = (i ~/ 2) < 2;
        return Expanded(child: Container(height: 3, color: done ? AppTheme.primaryGreen : const Color(0xFFD4E6DA)));
      }
      final idx = i ~/ 2;
      final done = idx < 3;
      final active = idx == 2;
      return Column(children: [
        Container(width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: done ? AppTheme.primaryGreen : Colors.white,
            border: Border.all(color: done || active ? AppTheme.primaryGreen : const Color(0xFFD4E6DA), width: 2)),
          child: Center(child: done
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : const SizedBox())),
      ]);
    })),
    const SizedBox(height: 10),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _steps.map((s) {
      final idx = _steps.indexOf(s);
      final active = idx <= 2;
      return SizedBox(width: 72, child: Text(s, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppTheme.primaryGreen : AppTheme.textSecondary)));
    }).toList()),
    const SizedBox(height: 20),
    const Divider(color: Color(0xFFEAF1EB)),
    const SizedBox(height: 16),
    _trackEvent('08 Jun 2025 14:30', 'Out for Delivery', 'Carrier picked up from Andheri Hub', true),
    _trackEvent('07 Jun 2025 09:15', 'Dispatched',       'Left VESIT dispatch center',           false),
    _trackEvent('06 Jun 2025 18:00', 'Confirmed',         'Order confirmed by seller',            false),
    _trackEvent('05 Jun 2025 12:42', 'Order Placed',      'Payment received',                     false),
  ]));

  Widget _trackEvent(String time, String title, String sub, bool latest) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 12, height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: latest ? AppTheme.primaryGreen : Colors.grey.shade300,
            border: Border.all(color: latest ? AppTheme.primaryGreen : Colors.grey.shade300, width: 2))),
        if (!latest) Container(width: 1, height: 36, color: Colors.grey.shade200),
      ]),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
          color: latest ? AppTheme.primaryGreen : AppTheme.textPrimary)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
      ])),
    ]),
  );

  Widget _itemsCard() => _card('Items in Order', Icons.inventory_2_outlined, child: Column(children: [
    _orderItem('Arduino Uno Rev3', 'Electronic', 1, 449),
    const Divider(color: Color(0xFFEAF1EB)),
    const SizedBox(height: 12),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const Text('Rs.449', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
    ]),
  ]));

  Widget _orderItem(String name, String cat, int qty, double price) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.memory, color: AppTheme.primaryGreen, size: 26)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Text(cat, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Rs.${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryGreen)),
        Text('Qty: $qty', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ]),
    ]),
  );

  Widget _infoCard(String title, List<Widget> rows) => _card(title, null, child: Column(children: rows));

  Widget _infoRow(IconData ic, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(ic, size: 16, color: AppTheme.primaryGreen),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
    ]),
  );

  Widget _ecoCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.primaryLight.withOpacity(0.4))),
    child: Column(children: [
      const Icon(Icons.eco, size: 32, color: AppTheme.primaryGreen),
      const SizedBox(height: 12),
      const Text('Eco Impact', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryGreen)),
      const SizedBox(height: 6),
      const Text('This order prevented 0.9 kg CO₂ and saved 1 item from landfill.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen, height: 1.5)),
    ]),
  );

  Widget _card(String title, IconData? ic, {required Widget child}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (ic != null) ...[Icon(ic, size: 20, color: AppTheme.primaryGreen), const SizedBox(width: 10)],
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 20),
      child,
    ]),
  );

  Widget _statusBadge(String status) {
    const c = Color(0xFF3182CE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: c)),
        const SizedBox(width: 6),
        Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c)),
      ]));
  }

  Widget _mobile(BuildContext context) {
    const status = 'In Transit';
    return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EFE8)),
        ),
        child: Text(
          'Order Status: ${_erpLifecycleStatus(status)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryDark),
        ),
      ),
      const SizedBox(height: 12),
      _trackingCard(),
      const SizedBox(height: 16),
      _itemsCard(),
      const SizedBox(height: 16),
      _infoCard('Shipping Address', [
        _infoRow(Icons.person_outline, 'John Doe'),
        _infoRow(Icons.phone_outlined, '+91 9800000000'),
        _infoRow(Icons.location_on_outlined, '102 Green Lane, Mumbai - 400001'),
      ]),
      const SizedBox(height: 16),
      _ecoCard(),
      const SizedBox(height: 24),
    ],
  );
  }
}
