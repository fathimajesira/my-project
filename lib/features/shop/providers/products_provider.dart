import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsService _productsService = ProductsService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productsService.getProducts();
    } catch (e) {
      _error = e.toString();
      print('Load Products Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProductDetails(String productId) async {
    try {
      return await _productsService.getProduct(productId);
    } catch (e) {
      print('Get Product Details Error: $e');
      return null;
    }
  }

  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productsService.getProductsByCategory(category);
    } catch (e) {
      _error = e.toString();
      print('Load Products by Category Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      notifyListeners();
      return;
    }
    final filtered = _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    _products = filtered;
    notifyListeners();
  }

  Future<void> seedProducts(List<Product> products) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _productsService.seedProducts(products);
      await loadProducts(); // Refresh list after seeding
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static List<Product> get sampleProducts => [
        Product(
          id: '1',
          name: 'Premium Silk Dress',
          price: 12500.0,
          imageUrl: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=500',
          description: 'A luxurious silk dress perfect for evening events. Features a sleek silhouette and elegant drape.',
          sizes: ['S', 'M', 'L'],
          category: 'Dresses',
        ),
        Product(
          id: '2',
          name: 'Classic Leather Jacket',
          price: 18000.0,
          imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500',
          description: 'Timeless leather jacket crafted from premium grade hide. Features multiple pockets and a tailored fit.',
          sizes: ['M', 'L', 'XL'],
          category: 'Jackets',
        ),
        Product(
          id: '3',
          name: 'Slim Fit Cotton Shirt',
          price: 4500.0,
          imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87034a264c6?w=500',
          description: 'Breathable cotton shirt with a slim fit design. Ideal for both office and casual wear.',
          sizes: ['S', 'M', 'L', 'XL'],
          category: 'Shirts',
        ),
        Product(
          id: '4',
          name: 'Designer Wool Coat',
          price: 25000.0,
          imageUrl: 'https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?w=500',
          description: 'Exquisite wool coat for winter. Provides warmth without compromising on style.',
          sizes: ['M', 'L'],
          category: 'Coats',
        ),
      ];
}
