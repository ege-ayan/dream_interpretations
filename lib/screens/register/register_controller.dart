import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        await _auth.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
          surnameController.text.trim(),
        );
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        errorMessage = "Kayıt başarısız: ${e.toString()}";
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifre girin';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermelidir';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermelidir';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir';
    }
    return null;
  }
}
