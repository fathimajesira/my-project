import 'package:flutter/material.dart';

class CheckoutState {
  final String? selectedAddressId;
  final String deliveryMethod;
  final String paymentMethod;
  final bool isLoading;
  final String? error;

  CheckoutState({
    this.selectedAddressId,
    this.deliveryMethod = 'standard',
    this.paymentMethod = 'card',
    this.isLoading = false,
    this.error,
  });

  CheckoutState copyWith({
    String? selectedAddressId,
    String? deliveryMethod,
    String? paymentMethod,
    bool? isLoading,
    String? error,
  }) {
    return CheckoutState(
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
