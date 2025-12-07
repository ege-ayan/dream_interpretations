import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DreamService {
  final String _baseUrl =
      'https://dream-interpretations-backend.vercel.app/api/dreams/interpret';

  Future<String> interpretDream(String dream) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu açık değil.');
      }
      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'dream': dream}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['interpretation'] ?? 'Yorum bulunamadı.';
      } else {
        throw Exception('Sunucu hatası: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }
}
