import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> sendResetEmail() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _auth.resetPassword(emailController.text.trim());
      _successMessage =
          'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.';
      emailController.clear();
    } catch (e) {
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
