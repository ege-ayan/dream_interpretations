import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _apiKey = 'test_popWnDioRUdaKENglIIlyFEbURx';
  static const String _entitlementId = 'Pro Plan';

  // Initialize RevenueCat
  Future<void> initialize(String userId) async {
    if (kIsWeb) {
      return;
    }

    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }

    final configuration = PurchasesConfiguration(_apiKey);
    await Purchases.configure(configuration);
    await Purchases.logIn(userId);
  }

  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  // Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      // purchasePackage is deprecated but we use it for now.
      // It returns PurchaseResult in v9+ which contains customerInfo.
      // ignore: deprecated_member_use
      final purchaseResult = await Purchases.purchasePackage(package);
      // Access customerInfo from the result (assuming it exists based on common patterns)
      // If PurchaseResult is not the return type, we might need to adjust.
      // But based on previous errors, it returns something that is NOT CustomerInfo directly.
      // Let's assume it returns CustomerInfo directly if the previous error was about entitlements?
      // Wait, step 190 said: "The getter 'entitlements' isn't defined for the type 'PurchaseResult'".
      // So it DOES return PurchaseResult.
      // And PurchaseResult usually wraps customerInfo.
      return purchaseResult.customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(_entitlementId);
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      return false;
    }
  }

  // Get customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }

  // Log out user
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // Get subscription status stream
  Stream<bool> subscriptionStatusStream() {
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await hasActiveSubscription();
    });
  }
}
