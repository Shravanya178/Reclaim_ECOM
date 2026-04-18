import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:reclaim/core/services/erp_crm_intelligence_service.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/ecommerce_backdrop.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/ecommerce/models/order.dart' as ecom;
import 'package:reclaim/features/ecommerce/providers/local_cart_provider.dart';
import 'package:reclaim/features/ecommerce/providers/order_provider.dart';

class _Order {
  final String id, status, date, items;
  final double total;
  const _Order(this.id, this.status, this.date, this.items, this.total);
}

const _demoOrders = [
  _Order('ORD-1029', 'Delivered',   '12 Jun 2025', '3 items', 1240),
  _Order('ORD-1021', 'In Transit',  '08 Jun 2025', '1 item',   449),
  _Order('ORD-1018', 'Processing',  '05 Jun 2025', '5 items', 2310),
  _Order('ORD-1011', 'Delivered',   '28 May 2025', '2 items',  670),
  _Order('ORD-1004', 'Cancelled',   '20 May 2025', '1 item',   299),
];

/// Map Supabase Order → display _Order
_Order _orderFromApi(ecom.Order o) {
  final itemCount = o.items?.length ?? 1;
  return _Order(
    o.orderNumber,
    _statusLabel(o.status),
    DateFormat('dd MMM yyyy').format(o.createdAt),
    '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
    o.totalAmount,
  );
}

String _statusLabel(ecom.OrderStatus s) => switch (s) {
  ecom.OrderStatus.delivered  => 'Delivered',
  ecom.OrderStatus.shipped    => 'In Transit',
  ecom.OrderStatus.processing => 'Processing',
  ecom.OrderStatus.confirmed  => 'Processing',
  ecom.OrderStatus.pending    => 'Processing',
  ecom.OrderStatus.cancelled  => 'Cancelled',
  ecom.OrderStatus.refunded   => 'Cancelled',
};

String _erpLifecycleStatus(String status) {
  if (status == 'Delivered') return 'Completed';
  if (status == 'Cancelled') return 'Cancelled';
  return 'Processing';
}

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    final cartCount = ref.watch(localCartCountProvider);
    final ordersAsync = ref.watch(userOrdersProvider);

    // Use real orders if logged in and loaded; fall back to demo data otherwise
    final orders = ordersAsync.when(
      data:    (list) => list.isNotEmpty ? list.map(_orderFromApi).toList() : List<_Order>.from(_demoOrders),
      loading: ()       => List<_Order>.from(_demoOrders),
      error:   (_, __)  => List<_Order>.from(_demoOrders),
    );
    final isLoading = ordersAsync.isLoading;

    return ResponsiveScaffold(
      currentRoute: '/orders',
      cartItemCount: cartCount,
      mobileAppBar: isMobile ? AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w700)),
      ) : null,
      body: EcommerceBackdrop(
        imageUrl:
            'https://images.unsplash.com/photo-1510798831971-661eb04b3739?auto=format&fit=crop&w=1800&q=80',
        child: isMobile
            ? _mobile(context, orders, isLoading)
            : _desktop(context, orders, isLoading),
      ),
    );
  }

  Widget _desktop(BuildContext context, List<_Order> orders, bool isLoading) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(child: Column(children: [
      // Page header banner
      Container(width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 48), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Orders', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Track and manage all your purchases', style: TextStyle(color: Colors.white70, fontSize: 15)),
          ])),
        ))),
      // Content
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(children: [
              FutureBuilder<FlowPlaybook>(
                future: ErpCrmIntelligenceService.instance.getFlowPlaybook(role: 'customer'),
                builder: (context, snapshot) {
                  final p = snapshot.data;
                  if (p == null) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FCF9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4E6DA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CRM ${p.crmStage.toUpperCase()} | SCM ${p.scmMode} | ${p.crmNextAction}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                ErpCrmIntelligenceService.instance.recordRetentionAction('reorder_from_history');
                                context.go('/shop');
                              },
                              icon: const Icon(Icons.repeat, size: 16),
                              label: const Text('Reorder Essentials'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                ErpCrmIntelligenceService.instance.recordRetentionAction('support_sla_request');
                                context.go('/notifications');
                              },
                              icon: const Icon(Icons.support_agent, size: 16),
                              label: const Text('Raise Support SLA'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            _statsRow(orders),
            const SizedBox(height: 32),
            if (isLoading)
              const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
            if (!isLoading)
              _ordersTable(context, orders),
          ]),
        ),
      )),
      const WebFooter(),
    ]));
  }

  Widget _statsRow(List<_Order> orders) {
    final total     = orders.length;
    final delivered = orders.where((o) => o.status == 'Delivered').length;
    final transit   = orders.where((o) => o.status == 'In Transit').length;
    final cancelled = orders.where((o) => o.status == 'Cancelled').length;
    final stats = [
      ('$total',     'Total Orders', Icons.receipt_long_outlined,    AppTheme.primaryGreen),
      ('$delivered', 'Delivered',    Icons.check_circle_outline,     const Color(0xFF38A169)),
      ('$transit',   'In Transit',   Icons.local_shipping_outlined,  const Color(0xFF3182CE)),
      ('$cancelled', 'Cancelled',    Icons.cancel_outlined,          Colors.redAccent),
    ];
    return Row(children: stats.map((s) => Expanded(child: Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFEAF3ED), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: s.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(s.$3, color: s.$4, size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.$1, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: s.$4)),
          Text(s.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ]),
    ))).toList());
  }

  Widget _ordersTable(BuildContext context, List<_Order> orders) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFEAF3ED), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(color: Color(0xFFF7FAF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: const Row(children: [
            Expanded(flex: 2, child: Text('ORDER ID',   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
            Expanded(flex: 2, child: Text('DATE',       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
            Expanded(flex: 2, child: Text('ITEMS',      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
            Expanded(flex: 2, child: Text('TOTAL',      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
            Expanded(flex: 2, child: Text('STATUS',     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
            Expanded(flex: 1, child: SizedBox()),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFEAF1EB)),
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text('No orders yet.', style: TextStyle(color: AppTheme.textSecondary)),
          )
        else
          ...orders.map((o) => _orderRow(context, o)),
      ]),
    );
  }

  Widget _orderRow(BuildContext context, _Order o) {
    Color sc; IconData si;
    switch (o.status) {
      case 'Delivered':  sc = const Color(0xFF38A169); si = Icons.check_circle; break;
      case 'In Transit': sc = const Color(0xFF3182CE); si = Icons.local_shipping; break;
      case 'Processing': sc = const Color(0xFFD69E2E); si = Icons.hourglass_top; break;
      default:            sc = Colors.redAccent; si = Icons.cancel;
    }
    return InkWell(
      onTap: () => context.go('/order/${o.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F5F1)))),
        child: Row(children: [
          Expanded(flex: 2, child: Text(o.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryGreen))),
          Expanded(flex: 2, child: Text(o.date, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
          Expanded(flex: 2, child: Text(o.items, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
          Expanded(flex: 2, child: Text('Rs.${o.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(si, size: 13, color: sc),
                    const SizedBox(width: 5),
                    Text(o.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sc)),
                  ]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order Status: ${_erpLifecycleStatus(o.status)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryDark),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: TextButton(onPressed: () => context.go('/order/${o.id}'), child: const Text('View'))),
        ]),
      ),
    );
  }

  // ── MOBILE ────────────────────────────────────────────
  Widget _mobile(BuildContext context, List<_Order> orders, bool isLoading) {
    if (isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(64),
        child: CircularProgressIndicator(),
      ));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder<FlowPlaybook>(
          future: ErpCrmIntelligenceService.instance.getFlowPlaybook(role: 'customer'),
          builder: (context, snapshot) {
            final p = snapshot.data;
            if (p == null) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FCF9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4E6DA)),
              ),
              child: Text(
                'Next: ${p.crmNextAction}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
        ...orders.map((o) => _mobileOrderCard(context, o)),
      ],
    );
  }

  Widget _mobileOrderCard(BuildContext context, _Order o) {
    Color sc; IconData si;
    switch (o.status) {
      case 'Delivered':  sc = const Color(0xFF38A169); si = Icons.check_circle; break;
      case 'In Transit': sc = const Color(0xFF3182CE); si = Icons.local_shipping; break;
      case 'Processing': sc = const Color(0xFFD69E2E); si = Icons.hourglass_top; break;
      default:            sc = Colors.redAccent; si = Icons.cancel;
    }
    return GestureDetector(
      onTap: () => context.go('/order/${o.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFEAF3ED), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EFE8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,3))]),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(o.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryGreen)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(si, size: 12, color: sc),
                const SizedBox(width: 4),
                Text(o.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
              ])),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(o.date, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            Text(o.items, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            Text('Rs.${o.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Order Status: ${_erpLifecycleStatus(o.status)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
