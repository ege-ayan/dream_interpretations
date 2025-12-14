import 'package:flutter/material.dart';

class SubscriptionController extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Mock subscription data
  final Map<String, dynamic> subscriptionOffer = {
    'id': 'premium_monthly',
    'title': 'Premium Abonelik',
    'description': 'Sınırsız rüya yorumu ve premium özellikler',
    'price': '₺29.99/ay',
    'features': [
      'Sınırsız rüya yorumu',
      'Detaylı analiz',
      'Özel yorum türleri',
      'Reklamsız deneyim',
      'Öncelikli destek'
    ],
  };

  SubscriptionController();

  // Mock subscription purchase - does nothing
  Future<void> purchaseSubscription() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }

  // Mock restore purchase - does nothing
  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }
}
