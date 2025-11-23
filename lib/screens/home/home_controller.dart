import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/dream_service.dart';

class HomeController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final DreamService _dreamService = DreamService();
  final TextEditingController dreamController = TextEditingController();

  String? interpretation;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    dreamController.dispose();
    super.dispose();
  }

  Future<void> interpretDream(BuildContext context) async {
    if (dreamController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen rüyanızı yazın.')));
      return;
    }

    isLoading = true;
    errorMessage = null;
    interpretation = null;
    notifyListeners();

    try {
      final result = await _dreamService.interpretDream(
        dreamController.text.trim(),
      );
      interpretation = result;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
