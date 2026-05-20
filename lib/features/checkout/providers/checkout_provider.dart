import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:elixra_fashion/core/models/address_model.dart';
import 'package:elixra_fashion/core/models/order_model.dart';
import '../models/checkout_state.dart';

class CheckoutProvider extends ChangeNotifier {
  AddressModel? _selectedAddress;
  String _deliveryMethod = 'standard';
  String _paymentMethod = 'card';
  double _deliveryCharge = 0;
  bool _isLoading = false;
  String? _error;

  AddressModel? get selectedAddress => _selectedAddress;
  String get deliveryMethod => _deliveryMethod;
  String get paymentMethod => _paymentMethod;
  double get deliveryCharge => _deliveryCharge;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setDeliveryMethod(String method) {
    _deliveryMethod = method;
    _deliveryCharge = method == 'express' ? 15.0 : 0;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  bool isReadyToCheckout() {
    return _selectedAddress != null && _paymentMethod.isNotEmpty;
  }

  void reset() {
    _selectedAddress = null;
    _deliveryMethod = 'standard';
    _paymentMethod = 'card';
    _deliveryCharge = 0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
