import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/dream_model.dart';
import '../../services/dream_service.dart';
import '../../services/firestore_service.dart';

class ChatController extends ChangeNotifier {
  final DreamService _dreamService = DreamService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentDreamId;
  String _dreamText = '';

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get dreamText => _dreamText;

  ChatController({String? dreamId, String initialDream = ''}) {
    _currentDreamId = dreamId;
    _dreamText = initialDream;
    if (dreamId != null) {
      _loadExistingChat(dreamId);
    } else if (initialDream.isNotEmpty) {
      _startNewChat(initialDream);
    }
  }

  Future<void> _loadExistingChat(String dreamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dream = await _firestoreService.getDream(dreamId);
      if (dream != null) {
        _messages = dream.messages;
        _dreamText = dream.dreamText;
      }
    } catch (e) {
      _errorMessage = 'Sohbet yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> _startNewChat(String dream) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add user's dream message
      final userMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: dream,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      notifyListeners();
      _scrollToBottom();

      // Get AI interpretation
      final interpretation = await _dreamService.interpretDream(dream);

      // Add AI response
      final aiMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: interpretation,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);

      // Save to Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final dreamModel = DreamModel(
        id: '',
        userId: userId,
        dreamText: dream,
        interpretation: interpretation,
        timestamp: DateTime.now(),
        messages: _messages,
      );

      _currentDreamId = await _firestoreService.saveDream(dreamModel);
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      // Remove the user message if there was an error
      if (_messages.isNotEmpty && _messages.last.isUser) {
        _messages.removeLast();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    messageController.clear();
    _isLoading = true;
    _errorMessage = null;

    // Add user message
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();
    _scrollToBottom();

    try {
      // For follow-up questions, we'll use the same dream service
      // In a real app, you'd send the conversation history
      final response = await _dreamService.interpretDream(
        'Önceki rüya: $_dreamText\n\nSoru: $message',
      );

      // Add AI response
      final aiMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);

      // Update Firestore
      if (_currentDreamId != null) {
        await _firestoreService.addMessageToDream(_currentDreamId!, aiMessage);
        await _firestoreService.addMessageToDream(
          _currentDreamId!,
          userMessage,
        );
      }
    } catch (e) {
      _errorMessage = 'Mesaj gönderilemedi: $e';
      // Remove user message if there was an error
      if (_messages.isNotEmpty && _messages.last.isUser) {
        _messages.removeLast();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
