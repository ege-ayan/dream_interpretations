import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/dream_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final DreamService _dreamService = DreamService();
  final TextEditingController _dreamController = TextEditingController();
  String? _interpretation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    if (_dreamController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen rüyanızı yazın.')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _interpretation = null;
    });

    try {
      final result = await _dreamService.interpretDream(
        _dreamController.text.trim(),
      );
      setState(() {
        _interpretation = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rüya Tabirleri Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rüyanızı Anlatın',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dreamController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Rüyanızı detaylı bir şekilde buraya yazın...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _interpretDream,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Yorumla'),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            if (_interpretation != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rüya Yorumu:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _interpretation!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
