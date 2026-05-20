import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../../shop/models/product_model.dart';
import 'package:elixra_fashion/core/models/address_model.dart';
import 'package:elixra_fashion/core/models/payment_card_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  double get subtotal => totalAmount;
  double get total => totalAmount;

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress ?? AddressModel(
    id: 'default',
    label: 'Home',
    fullName: 'ALEXANDER STERLING',
    street: '742 Everest Terrace',
    city: 'Springfield',
    state: 'IL',
    zip: '62704',
    phone: '+1 555-0123',
    isDefault: true,
  );

  PaymentCardModel? _selectedCard;
  PaymentCardModel? get selectedCard => _selectedCard;

  CartProvider() {
    _loadCartFromPrefs();
  }

  // Persistence Logic
  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decodedData = json.decode(cartData);
        _items = decodedData.map((item) => CartItem.fromMap(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = json.encode(_items.map((item) => item.toMap()).toList());
      await prefs.setString('cart_items', cartData);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void setCard(PaymentCardModel card) {
    _selectedCard = card;
    notifyListeners();
  }

  void setAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addToCart(Product product, String selectedSize) {
    final existing = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedSize == selectedSize,
    );
    if (existing != -1) {
      _items[existing].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedSize: selectedSize));
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeFromCart(String id, String selectedSize) {
    _items.removeWhere(
      (item) => item.product.id == id && item.selectedSize == selectedSize,
    );
    _saveCartToPrefs();
    notifyListeners();
  }

  void updateQuantity(String id, String selectedSize, int qty) {
    final itemIndex = _items.indexWhere(
      (i) => i.product.id == id && i.selectedSize == selectedSize,
    );
    if (itemIndex != -1) {
      if (qty > 0) {
        _items[itemIndex].quantity = qty;
      } else {
        _items.removeAt(itemIndex);
      }
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _selectedAddress = null;
    _selectedCard = null;
    _saveCartToPrefs();
    notifyListeners();
  }
}
