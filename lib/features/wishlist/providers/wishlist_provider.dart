import 'package:flutter/material.dart';
import '../../shop/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  bool isWishlisted(String id) {
    return _items.any((item) => item.id == id);
  }

  void toggleWishlist(Product product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);
    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeFromWishlist(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
