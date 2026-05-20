import 'package:flutter/material.dart';
import 'package:elixra_fashion/core/services/firestore_service.dart';
import 'package:elixra_fashion/core/models/user_model.dart';
import 'package:elixra_fashion/core/models/address_model.dart';
import 'package:elixra_fashion/core/models/payment_card_model.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  List<AddressModel> _addresses = [];
  List<PaymentCardModel> _cards = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<AddressModel> get addresses => _addresses;
  List<PaymentCardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _firestoreService.getUser(userId);
      await loadAddresses(userId);
      await loadCards(userId);
    } catch (e) {
      _error = e.toString();
      print('Load User Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAddresses(String userId) async {
    try {
      _addresses = await _firestoreService.getAddresses(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Load Addresses Error: $e');
    }
  }

  Future<void> updateProfile(String userId, String name, String? phone) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateUser(userId, {
        'name': name,
        'phone': phone,
      });
      _currentUser = _currentUser?.copyWith(name: name, phone: phone);
    } catch (e) {
      _error = e.toString();
      print('Update Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String userId, AddressModel address) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.addAddress(userId, address);
      _addresses.add(address);
    } catch (e) {
      _error = e.toString();
      print('Add Address Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      await _firestoreService.deleteAddress(userId, addressId);
      _addresses.removeWhere((addr) => addr.id == addressId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Delete Address Error: $e');
    }
  }

  Future<void> loadCards(String userId) async {
    try {
      final cardData = await _firestoreService.getCards(userId);
      _cards = cardData.map((data) => PaymentCardModel.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      print('Load Cards Error: $e');
    }
  }

  Future<void> addCard(String userId, PaymentCardModel card) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.addCard(userId, card.toMap());
      _cards.add(card);
    } catch (e) {
      print('Add Card Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCard(String userId, String cardId) async {
    try {
      await _firestoreService.deleteCard(userId, cardId);
      _cards.removeWhere((card) => card.id == cardId);
      notifyListeners();
    } catch (e) {
      print('Delete Card Error: $e');
    }
  }
}
