import 'package:flutter/material.dart';
import 'package:elixra_fashion/core/services/firestore_service.dart';
import 'package:elixra_fashion/core/models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserOrders(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _firestoreService.getUserOrders(userId);
    } catch (e) {
      _error = e.toString();
      print('Load Orders Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> getOrderDetails(String orderId) async {
    try {
      return await _firestoreService.getOrder(orderId);
    } catch (e) {
      _error = e.toString();
      print('Get Order Details Error: $e');
      return null;
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.createOrder(order);
      _orders.insert(0, order);
    } catch (e) {
      _error = e.toString();
      print('Create Order Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      print('Update Order Status Error: $e');
    }
  }
}
