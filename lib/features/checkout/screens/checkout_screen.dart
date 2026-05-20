import 'package:flutter/material.dart';
import 'package:elixra_fashion/shared/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:elixra_fashion/features/cart/providers/cart_provider.dart';
import 'package:elixra_fashion/features/auth/providers/auth_provider.dart';
import 'package:elixra_fashion/features/profile/providers/user_provider.dart';
import 'package:elixra_fashion/core/models/order_model.dart';
import 'package:elixra_fashion/core/models/address_model.dart';
import 'package:elixra_fashion/core/models/payment_card_model.dart';
import 'package:elixra_fashion/core/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = auth.currentUser;

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('CHECKOUT')),
        body: const Center(child: Text('YOUR BAG IS EMPTY')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CHECKOUT', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('YOUR ITEMS'),
                        const SizedBox(height: 16),
                        _buildCartItemsList(cart),
                        const SizedBox(height: 32),
                        _buildSectionHeader('SHIPPING ADDRESS'),
                        const SizedBox(height: 16),
                        _buildAddressSection(cart, userProvider),
                        const SizedBox(height: 32),
                        _buildSectionHeader('PAYMENT METHOD'),
                        const SizedBox(height: 16),
                        _buildPaymentSection(cart, userProvider),
                        const SizedBox(height: 32),
                        _buildSectionHeader('ORDER SUMMARY'),
                        const SizedBox(height: 16),
                        _buildSummaryItem('Subtotal', cart.totalAmount),
                        _buildSummaryItem('Shipping', 0.0),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            Text('Rs. ${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 100), // Space for footer
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: 'PLACE ORDER',
                onPressed: _isProcessing ? null : () => _handlePlaceOrder(context, cart, user?.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black54),
    );
  }

  Widget _buildCartItemsList(CartProvider cart) {
    return Column(
      children: cart.items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(
                  item.product.imageUrl,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], width: 80, height: 100, child: const Icon(Icons.image_not_supported)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Size: ${item.selectedSize}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rs. ${item.product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            _buildCircleButton(Icons.remove, () => cart.updateQuantity(item.product.id, item.selectedSize, item.quantity - 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            _buildCircleButton(Icons.add, () => cart.updateQuantity(item.product.id, item.selectedSize, item.quantity + 1)),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => cart.removeFromCart(item.product.id, item.selectedSize),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildAddressSection(CartProvider cart, UserProvider userProvider) {
    final address = cart.selectedAddress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(address?.label.toUpperCase() ?? 'SELECT ADDRESS', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black38)),
              TextButton(
                onPressed: () => _showAddressSelection(context, userProvider, cart),
                child: const Text('CHANGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
          if (address != null) ...[
            Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text('${address.street}, ${address.city}\n${address.state} ${address.zip}, ${address.phone}', style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSection(CartProvider cart, UserProvider userProvider) {
    final card = cart.selectedCard;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card?.cardType.toUpperCase() ?? 'SELECT PAYMENT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black38)),
              TextButton(
                onPressed: () => _showPaymentSelection(context, userProvider, cart),
                child: const Text('CHANGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
          if (card != null) ...[
            Row(
              children: [
                const Icon(Icons.credit_card, size: 20),
                const SizedBox(width: 12),
                Text('**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Text(card.cardHolderName, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ] else
            const Text('No card selected', style: TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text('Rs. ${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddressSelection(BuildContext context, UserProvider userProvider, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SELECT ADDRESS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 16),
            if (userProvider.addresses.isEmpty)
              const Text('No addresses saved')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: userProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final addr = userProvider.addresses[index];
                    return ListTile(
                      title: Text(addr.fullName),
                      subtitle: Text('${addr.street}, ${addr.city}'),
                      onTap: () {
                        cart.setAddress(addr);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSelection(BuildContext context, UserProvider userProvider, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SELECT PAYMENT METHOD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 16),
            if (userProvider.cards.isEmpty)
              const Text('No cards saved')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: userProvider.cards.length,
                  itemBuilder: (context, index) {
                    final card = userProvider.cards[index];
                    return ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: Text('**** ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                      onTap: () {
                        cart.setCard(card);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, CartProvider cart, String? userId) async {
    if (userId == null) return;
    if (cart.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PLEASE SELECT A SHIPPING ADDRESS')));
      return;
    }
    if (cart.selectedCard == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PLEASE SELECT A PAYMENT METHOD')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final order = OrderModel(
        id: const Uuid().v4(),
        userId: userId,
        items: cart.items.map((item) => OrderItem(
          productId: item.product.id,
          productName: item.product.name,
          quantity: item.quantity,
          selectedSize: item.selectedSize,
          price: item.product.price,
        )).toList(),
        totalPrice: cart.totalAmount,
        createdAt: DateTime.now(),
        shippingAddress: cart.selectedAddress!,
        paymentMethod: '${cart.selectedCard!.cardType} (****${cart.selectedCard!.cardNumber.substring(cart.selectedCard!.cardNumber.length - 4)})',
      );

      await _firestoreService.createOrder(order);
      cart.clearCart();

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ORDER PLACED SUCCESSFULLY'), backgroundColor: Colors.black),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
