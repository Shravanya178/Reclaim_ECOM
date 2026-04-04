import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reclaim/core/services/razorpay_web_service.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/ecommerce/providers/local_cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0; // 0=Shipping, 1=Payment, 2=Review
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController(text: 'Dev User');
  final _emailCtrl   = TextEditingController(text: 'devuser@example.com');
  final _phoneCtrl   = TextEditingController(text: '9876543210');
  final _address1Ctrl= TextEditingController(text: '12, Science Block');
  final _cityCtrl    = TextEditingController(text: 'Bengaluru');
  final _pinCtrl     = TextEditingController(text: '560001');
  String _payMethod  = 'upi';
  bool _placing = false;
  bool _placed  = false;
  String _orderId = '';

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _address1Ctrl.dispose(); _cityCtrl.dispose(); _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final cartCount = ref.watch(localCartCountProvider);

    if (_placed) return _buildSuccess(context, isMobile);

    return ResponsiveScaffold(
      currentRoute: '/checkout',
      cartItemCount: cartCount,
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.go('/cart')),
              title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w700)))
          : null,
      body: SingleChildScrollView(child: Column(children: [
        if (!isMobile) _buildPageHeader(context),
        Center(child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(MediaQuery.of(context).size.width)),
          child: Padding(
            padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: isMobile ? _buildMobile(context) : _buildDesktop(context),
          ),
        )),
        if (!isMobile) const WebFooter(),
      ])),
    );
  }

  // ─── Page header ──────────────────────────────────────────────────────────
  Widget _buildPageHeader(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      begin: Alignment.topLeft, end: Alignment.bottomRight)),
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 56),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
      SizedBox(height: 6),
      Text('Secure, eco-conscious checkout', style: TextStyle(color: Colors.white70, fontSize: 14)),
    ]),
  );

  // ─── Stepper indicator ────────────────────────────────────────────────────
  Widget _buildStepper() {
    const steps = ['Shipping', 'Payment', 'Review'];
    return Row(children: List.generate(steps.length * 2 - 1, (i) {
      if (i.isOdd) return Expanded(child: Container(height: 2,
        color: (i ~/ 2) < _step ? AppTheme.primaryGreen : const Color(0xFFD4E6DA)));
      final idx = i ~/ 2;
      final done = idx < _step;
      final active = idx == _step;
      return Column(children: [
        AnimatedContainer(duration: const Duration(milliseconds: 250),
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppTheme.primaryGreen : (active ? AppTheme.primaryGreen : Colors.white),
            border: Border.all(color: active || done ? AppTheme.primaryGreen : const Color(0xFFD4E6DA), width: 2)),
          child: Center(child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Text('${idx + 1}', style: TextStyle(fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.grey.shade400)))),
        const SizedBox(height: 6),
        Text(steps[idx], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: active || done ? AppTheme.primaryGreen : Colors.grey.shade400)),
      ]);
    }));
  }

  // ─── Desktop layout ───────────────────────────────────────────────────────
  Widget _buildDesktop(BuildContext context) {
    final items = ref.watch(localCartProvider);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 3, child: Column(children: [
        _buildStepper(),
        const SizedBox(height: 32),
        _buildStepCard(context),
      ])),
      const SizedBox(width: 32),
      SizedBox(width: 340, child: _buildOrderSummary(items)),
    ]);
  }

  Widget _buildMobile(BuildContext context) {
    final items = ref.watch(localCartProvider);
    return Column(children: [
      _buildStepper(),
      const SizedBox(height: 20),
      _buildStepCard(context),
      const SizedBox(height: 20),
      _buildOrderSummary(items),
    ]);
  }

  // ─── Step card ────────────────────────────────────────────────────────────
  Widget _buildStepCard(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))]),
    padding: const EdgeInsets.all(28),
    child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_step == 0) ..._shippingStep(),
      if (_step == 1) ..._paymentStep(),
      if (_step == 2) ..._reviewStep(),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        if (_step > 0)
          OutlinedButton.icon(
            onPressed: () => setState(() => _step--),
            icon: const Icon(Icons.arrow_back_outlined, size: 16),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))
        else const SizedBox(),
        ElevatedButton.icon(
          onPressed: _placing ? null : () => _onNext(context),
          icon: _step == 2
              ? (_placing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 18))
              : const Icon(Icons.arrow_forward_outlined, size: 18),
          label: Text(_step == 2 ? 'Place Order' : 'Continue',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _step == 2 ? const Color(0xFF1B4332) : AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4, shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4)),
        ),
      ]),
    ])),
  );

  void _onNext(BuildContext context) async {
    if (_step < 2) {
      if (_formKey.currentState!.validate()) setState(() => _step++);
      return;
    }

    // ── Cash on Delivery ───────────────────────────────────────────────────
    if (_payMethod == 'cod') {
      setState(() => _placing = true);
      await Future.delayed(const Duration(milliseconds: 800));
      _orderId = 'RCL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final items = ref.read(localCartProvider);
      final total = ref.read(localCartTotalProvider);
      await _saveOrderToSupabase(items, total + 49, paymentMethod: 'cod');
      ref.read(localCartProvider.notifier).clear();
      if (mounted) setState(() { _placing = false; _placed = true; });
      return;
    }

    // ── UPI / Card ─ open Razorpay checkout ────────────────────────────────
    final total = ref.read(localCartTotalProvider);
    final grand = total + 49;
    _orderId = 'RCL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    setState(() => _placing = true);

    RazorpayWebService.openCheckout(
      amountRupees: grand,
      orderId: _orderId,
      customerName: _nameCtrl.text,
      customerEmail: _emailCtrl.text,
      customerPhone: _phoneCtrl.text,

      onSuccess: (paymentId, rOrderId, signature) {
        // Client callback is not authoritative. Persist as pending verification.
        final items = ref.read(localCartProvider);
        final t = ref.read(localCartTotalProvider);
        _saveOrderToSupabase(
          items,
          t + 49,
          paymentMethod: 'razorpay',
          paymentId: paymentId,
        );
        ref.read(localCartProvider.notifier).clear();
        if (mounted) setState(() { _placing = false; _placed = true; });
      },

      onFailure: (code, message) {
        if (!mounted) return;
        setState(() => _placing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Payment failed: $message',
              style: const TextStyle(fontWeight: FontWeight.w600),
            )),
          ]),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ));
      },

      onDismiss: () {
        // User closed the Razorpay modal without paying
        if (mounted) setState(() => _placing = false);
      },
    );
  }

  // ─── SAVE ORDER TO SUPABASE ────────────────────────────────────────────────
  Future<void> _saveOrderToSupabase(
    List<LocalCartItem> items,
    double grand, {
    required String paymentMethod,
    String? paymentId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return; // not logged in — skip silently

      final subtotal = grand - 49;

      // Insert order
      final orderResponse = await supabase.from('orders').insert({
        'order_number': _orderId,
        'user_id': user.id,
        'total_amount': grand,
        'subtotal': subtotal,
        'tax_amount': 0.0,
        'shipping_amount': 49.0,
        'discount_amount': 0.0,
        'status': paymentMethod == 'cod' ? 'confirmed' : 'pending_payment',
        'payment_status': paymentMethod == 'cod' ? 'pending' : 'verification_pending',
        'shipping_address_line1': _address1Ctrl.text,
        'shipping_city': _cityCtrl.text,
        'shipping_state': _cityCtrl.text,
        'shipping_postal_code': _pinCtrl.text,
        'shipping_country': 'India',
        'shipping_phone': _phoneCtrl.text,
      }).select().single();

      final orderId = orderResponse['id'] as String;

      // Insert order items
      if (items.isNotEmpty) {
        final orderItems = items.map((item) => {
          'order_id': orderId,
          'material_name': item.name,
          'material_type': item.category,
          'material_image_url': item.imageUrl,
          'quantity': item.quantity,
          'unit_price': item.price,
          'subtotal': item.price * item.quantity,
        }).toList();
        await supabase.from('order_items').insert(orderItems);
      }

      // Record Razorpay payment in payments table if applicable
      if (paymentId != null) {
        await supabase.from('payments').insert({
          'order_id': orderId,
          'amount': grand,
          'payment_method': 'upi',
          'payment_status': 'verification_pending',
          'transaction_id': paymentId,
          'gateway_response': {
            'verification_state': 'pending_server_validation',
            'captured_at_client': DateTime.now().toIso8601String(),
          },
        });
      }
    } catch (e) {
      debugPrint('⚠ Failed to save order to Supabase: $e');
      // Fail silently — user already sees the success screen
    }
  }

  // ─── SHIPPING STEP ────────────────────────────────────────────────────────
  List<Widget> _shippingStep() => [
    const Text('Shipping Address', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
    const SizedBox(height: 4),
    Text('Where should we deliver your order?', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
    const SizedBox(height: 24),
    Row(children: [
      Expanded(child: _field(_nameCtrl, 'Full Name', Icons.person_outline, required: true)),
      const SizedBox(width: 16),
      Expanded(child: _field(_emailCtrl, 'Email', Icons.email_outlined, required: true)),
    ]),
    const SizedBox(height: 16),
    _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined, required: true, keyboardType: TextInputType.phone),
    const SizedBox(height: 16),
    _field(_address1Ctrl, 'Address Line', Icons.home_outlined, required: true),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _field(_cityCtrl, 'City', Icons.location_city_outlined, required: true)),
      const SizedBox(width: 16),
      Expanded(child: _field(_pinCtrl, 'PIN Code', Icons.pin_drop_outlined, required: true, keyboardType: TextInputType.number)),
    ]),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA8D5B5))),
      child: const Row(children: [
        Icon(Icons.local_shipping_outlined, color: AppTheme.primaryGreen, size: 22),
        SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Free Campus Delivery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryDark)),
          SizedBox(height: 2),
          Text('Orders delivered within campus within 2–3 business days.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
      ]),
    ),
  ];

  Widget _field(TextEditingController c, String label, IconData ic,
      {bool required = false, TextInputType? keyboardType}) => TextFormField(
    controller: c,
    keyboardType: keyboardType,
    validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
    decoration: InputDecoration(
      labelText: label, prefixIcon: Icon(ic, size: 19, color: AppTheme.primaryLight),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4E6DA))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4E6DA))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      filled: true, fillColor: const Color(0xFFF8FCF9), contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
  );

  // ─── PAYMENT STEP ─────────────────────────────────────────────────────────
  List<Widget> _paymentStep() {
    final total = ref.watch(localCartTotalProvider);
    return [
      const Text('Payment Method', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      const SizedBox(height: 4),
      Text('Choose how you want to pay.', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      const SizedBox(height: 24),
      _payOption('upi', 'UPI / Net Banking', Icons.account_balance_wallet_outlined,
        'PhonePe, GPay, Paytm, BHIM & all UPI apps', 'Instant'),
      const SizedBox(height: 12),
      _payOption('card', 'Credit / Debit Card', Icons.credit_card_outlined,
        'Visa, Mastercard, RuPay', 'Secure'),
      const SizedBox(height: 12),
      _payOption('cod', 'Cash on Delivery', Icons.currency_rupee_outlined,
        'Pay when you receive your order', 'Rs.0 extra'),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF0FAF4), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA8D5B5))),
        child: Row(children: [
          const Icon(Icons.lock_outlined, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('100% Secure Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryDark)),
            const SizedBox(height: 2),
            Text('Your order total is Rs.${total.toStringAsFixed(0)} + Rs.49 delivery',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ]),
      ),
    ];
  }

  Widget _payOption(String val, String label, IconData ic, String sub, String badge) {
    final sel = _payMethod == val;
    return InkWell(
      onTap: () => setState(() => _payMethod = val),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppTheme.primaryGreen : const Color(0xFFD4E6DA), width: sel ? 1.5 : 1)),
        child: Row(children: [
          AnimatedContainer(duration: const Duration(milliseconds: 180),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: sel ? AppTheme.primaryGreen : const Color(0xFFF3F4F6),
              shape: BoxShape.circle),
            child: Icon(ic, color: sel ? Colors.white : Colors.grey.shade500, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: sel ? AppTheme.primaryDark : AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: sel ? AppTheme.primaryGreen : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6)),
            child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: sel ? Colors.white : Colors.grey.shade500))),
          const SizedBox(width: 10),
          AnimatedContainer(duration: const Duration(milliseconds: 180),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sel ? AppTheme.primaryGreen : Colors.transparent,
              border: Border.all(color: sel ? AppTheme.primaryGreen : Colors.grey.shade300, width: 2)),
            child: sel ? const Icon(Icons.check, size: 14, color: Colors.white) : const SizedBox()),
        ]),
      ),
    );
  }

  // ─── REVIEW STEP ──────────────────────────────────────────────────────────
  List<Widget> _reviewStep() {
    final items = ref.watch(localCartProvider);
    final total  = ref.watch(localCartTotalProvider);
    final grand  = total + 49;
    return [
      const Text('Review Your Order', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      const SizedBox(height: 4),
      Text('Please confirm everything looks correct before placing.', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      const SizedBox(height: 24),
      // Items
      ...items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF8FCF9), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EFE8))),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 56, height: 56,
              child: item.imageUrl.startsWith('http')
                ? Image.network(item.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.primarySurface,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.primaryLight)))
                : Image.asset(item.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.primarySurface,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.primaryLight))))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('Qty: ${item.quantity}  •  ${item.condition}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Text('Rs.${(item.price * item.quantity).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryGreen)),
        ]),
      )),
      const Divider(height: 24, color: Color(0xFFE5EFE8)),
      // Delivery Address
      _reviewSection('Shipping To', Icons.home_outlined, [
        '${_nameCtrl.text}  •  ${_phoneCtrl.text}',
        _address1Ctrl.text,
        '${_cityCtrl.text} - ${_pinCtrl.text}',
      ]),
      const SizedBox(height: 14),
      _reviewSection('Payment', Icons.payment_outlined, [
        switch (_payMethod) {
          'upi'  => 'UPI / Net Banking',
          'card' => 'Credit / Debit Card',
          _      => 'Cash on Delivery',
        },
      ]),
      const Divider(height: 24, color: Color(0xFFE5EFE8)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
        Text('Rs.${grand.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryGreen)),
      ]),
    ];
  }

  Widget _reviewSection(String title, IconData ic, List<String> lines) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: AppTheme.primarySurface, shape: BoxShape.circle),
        child: Icon(ic, size: 18, color: AppTheme.primaryGreen)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        ...lines.map((l) => Text(l, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5))),
      ])),
    ],
  );

  // ─── ORDER SUMMARY SIDEBAR ─────────────────────────────────────────────────
  Widget _buildOrderSummary(List<LocalCartItem> items) {
    final total = items.fold(0.0, (s, i) => s + i.price * i.quantity);
    final grand = total + 49;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.receipt_long_outlined, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 8),
          const Text('Order Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('${item.name}  ×${item.quantity}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
            Text('Rs.${(item.price * item.quantity).toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
        )),
        const Divider(height: 20, color: Color(0xFFE5EFE8)),
        _sRow('Subtotal', 'Rs.${total.toStringAsFixed(0)}'),
        const SizedBox(height: 8),
        _sRow('Delivery', 'Rs.49'),
        const Divider(height: 20, color: Color(0xFFE5EFE8)),
        _sRow('Total', 'Rs.${grand.toStringAsFixed(0)}', bold: true),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Text('Secure Checkout', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }

  Widget _sRow(String l, String v, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(fontSize: 13, color: bold ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(v, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: bold ? AppTheme.primaryGreen : AppTheme.textPrimary)),
    ],
  );

  // ─── SUCCESS SCREEN ───────────────────────────────────────────────────────
  Widget _buildSuccess(BuildContext context, bool isMobile) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF9),
      body: Center(child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 32, offset: const Offset(0, 12))]),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 90, height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF52B788)]),
              shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 48)),
          const SizedBox(height: 24),
          const Text('Order Placed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
          const SizedBox(height: 10),
          Text('Order #$_orderId', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
          const SizedBox(height: 12),
          Text('Thank you for supporting sustainable material reuse.\nYou\'ll receive a confirmation at ${_emailCtrl.text}.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _successStat(Icons.eco, '1.2 kg', 'CO₂ Saved'),
              Container(width: 1, height: 40, color: const Color(0xFFA8D5B5)),
              _successStat(Icons.recycling, 'Reused', 'Materials'),
              Container(width: 1, height: 40, color: const Color(0xFFA8D5B5)),
              _successStat(Icons.local_shipping_outlined, '2-3 days', 'Delivery'),
            ]),
          ),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => context.go('/orders'),
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: const Text('Track Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.go('/shop'),
              icon: const Icon(Icons.storefront_outlined, size: 16),
              label: const Text('Shop More'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]),
        ]),
      )),
    );
  }

  Widget _successStat(IconData ic, String v, String l) => Column(children: [
    Icon(ic, color: AppTheme.primaryGreen, size: 22),
    const SizedBox(height: 4),
    Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryDark)),
    Text(l, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
  ]);
}
