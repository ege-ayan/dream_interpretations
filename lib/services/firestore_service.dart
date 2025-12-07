import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dream_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _dreamsCollection => _firestore.collection('dreams');

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Save a dream interpretation
  Future<String> saveDream(DreamModel dream) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final docRef = await _dreamsCollection.add(dream.toJson());
    return docRef.id;
  }

  // Update an existing dream
  Future<void> updateDream(String dreamId, DreamModel dream) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _dreamsCollection.doc(dreamId).update(dream.toJson());
  }

  // Get all dreams for current user
  Stream<List<DreamModel>> getUserDreams() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _dreamsCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DreamModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get recent dreams (limit)
  Stream<List<DreamModel>> getRecentDreams({int limit = 3}) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _dreamsCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DreamModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get a single dream by ID
  Future<DreamModel?> getDream(String dreamId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _dreamsCollection.doc(dreamId).get();
    if (doc.exists) {
      return DreamModel.fromFirestore(doc);
    }
    return null;
  }

  // Delete a dream
  Future<void> deleteDream(String dreamId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _dreamsCollection.doc(dreamId).delete();
  }

  // Add a message to a dream's chat
  Future<void> addMessageToDream(String dreamId, MessageModel message) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final dream = await getDream(dreamId);
    if (dream != null) {
      final updatedMessages = [...dream.messages, message];
      await _dreamsCollection.doc(dreamId).update({
        'messages': updatedMessages.map((m) => m.toJson()).toList(),
      });
    }
  }

  // Get user's dream count
  Future<int> getUserDreamCount() async {
    if (_currentUserId == null) {
      return 0;
    }

    final snapshot = await _dreamsCollection
        .where('userId', isEqualTo: _currentUserId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
