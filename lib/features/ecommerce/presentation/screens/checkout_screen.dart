import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reclaim/features/ecommerce/models/order.dart';
import 'package:reclaim/features/ecommerce/providers/cart_provider.dart';
import 'package:reclaim/features/ecommerce/providers/order_provider.dart';

/// Checkout Screen - Address and payment method selection
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;

  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(userCartProvider);

    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.white,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  const Text('Your cart is empty'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(_isDesktop ? 24 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: _isDesktop
                    ? _buildDesktopLayout(cart)
                    : _buildMobileLayout(cart),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDesktopLayout(dynamic cart) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Shipping Address'),
                  SizedBox(height: 16),
                  _buildAddressForm(),
                  SizedBox(height: 24),
                  
                  _buildSectionTitle('Payment Method'),
                  SizedBox(height: 16),
                  _buildPaymentMethodSelection(),
                  SizedBox(height: 24),
                  
                  _buildSectionTitle('Order Notes (Optional)'),
                  SizedBox(height: 12),
                  _buildNotesField(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(cart),
                SizedBox(height: 24),
                _buildPlaceOrderButton(cart),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(dynamic cart) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Shipping Address'),
          SizedBox(height: 12),
          _buildAddressForm(),
          SizedBox(height: 24),
          
          _buildSectionTitle('Payment Method'),
          SizedBox(height: 12),
          _buildPaymentMethodSelection(),
          SizedBox(height: 24),
          
          _buildSectionTitle('Order Notes (Optional)'),
          SizedBox(height: 12),
          _buildNotesField(),
          SizedBox(height: 24),
          
          _buildOrderSummary(cart),
          SizedBox(height: 24),
          
          _buildPlaceOrderButton(cart),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        TextFormField(
          controller: _addressLine1Controller,
          decoration: _inputDecoration('Address Line 1', hint: 'House/Flat No., Building Name'),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _addressLine2Controller,
          decoration: _inputDecoration('Address Line 2 (Optional)', hint: 'Street, Area, Landmark'),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: _inputDecoration('City'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: _inputDecoration('State'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                decoration: _inputDecoration('Postal Code'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      children: [
        _buildPaymentOption('upi', 'UPI', Icons.payment),
        _buildPaymentOption('credit_card', 'Credit/Debit Card', Icons.credit_card),
        _buildPaymentOption('net_banking', 'Net Banking', Icons.account_balance),
        _buildPaymentOption('wallet', 'Wallet', Icons.account_balance_wallet),
        _buildPaymentOption('cod', 'Cash on Delivery', Icons.money),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 12),
          Text(label),
        ],
      ),
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() {
          _selectedPaymentMethod = val!;
        });
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        hintText: 'Any special instructions?',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildOrderSummary(cart) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(height: 20),
            _buildSummaryRow('Items', '${cart.itemCount}'),
            _buildSummaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Tax (18%)', '₹${cart.taxAmount.toStringAsFixed(2)}'),
            _buildSummaryRow('Shipping', cart.shippingAmount == 0 ? 'FREE' : '₹${cart.shippingAmount.toStringAsFixed(2)}'),
            Divider(height: 20),
            _buildSummaryRow('Total', '₹${cart.total.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(cart) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _placeOrder(cart),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Place Order - ₹${cart.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _placeOrder(cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final address = ShippingAddress(
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        country: 'India',
        phone: _phoneController.text,
      );

      final createOrder = ref.read(createOrderProvider);
      final order = await createOrder(address, _notesController.text.isEmpty ? null : _notesController.text);

      if (order != null && mounted) {
        // Navigate to payment screen or order confirmation
        Navigator.pushReplacementNamed(context, '/order/${order.id}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${order.orderNumber} placed successfully!')),
        );
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
