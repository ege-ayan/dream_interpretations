import 'package:flutter/material.dart';
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
        errorMessage = "Giriş başarısız: ${e.toString()}";
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
