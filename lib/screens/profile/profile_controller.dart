import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final User? user = FirebaseAuth.instance.currentUser;

  int _dreamCount = 0;
  bool _isLoading = true;

  int get dreamCount => _dreamCount;
  bool get isLoading => _isLoading;

  String get displayName => user?.displayName ?? 'Kullanıcı';
  String get email => user?.email ?? '';
  DateTime? get createdAt => user?.metadata.creationTime;

  ProfileController() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dreamCount = await _firestoreService.getUserDreamCount();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadUserData();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
