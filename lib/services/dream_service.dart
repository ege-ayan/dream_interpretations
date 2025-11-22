import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DreamService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/interpret';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/interpret';
    } else {
      return 'http://localhost:3000/interpret';
    }
  }

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

      if (response.statusCode == 201) {
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
