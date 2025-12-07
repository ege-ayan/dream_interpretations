import 'package:flutter/material.dart';
import '../../models/dream_model.dart';
import '../../services/firestore_service.dart';
import '../../services/revenue_cat_service.dart';
import '../chat/chat_view.dart';

class HomeController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final RevenueCatService _revenueCatService = RevenueCatService();

  List<DreamModel> _recentDreams = [];
  bool _isLoading = true;
  bool _hasActiveSubscription = false;

  List<DreamModel> get recentDreams => _recentDreams;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _hasActiveSubscription;

  HomeController() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load subscription status
      _hasActiveSubscription = await _revenueCatService.hasActiveSubscription();

      // Load recent dreams (stream will update automatically)
      _firestoreService.getRecentDreams(limit: 3).listen((dreams) {
        _recentDreams = dreams;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  void navigateToChat(BuildContext context, String dreamText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(initialDream: dreamText),
      ),
    );
  }

  void navigateToChatWithDream(BuildContext context, DreamModel dream) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatView(dreamId: dream.id, initialDream: dream.dreamText),
      ),
    );
  }
}
