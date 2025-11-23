import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış.';
        case 'too-many-requests':
          return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
        case 'network-request-failed':
          return 'İnternet bağlantınızı kontrol edin.';
        default:
          return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
      }
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        await _auth.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      } catch (e) {
        errorMessage = _getErrorMessage(e);
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
