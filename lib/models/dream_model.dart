import 'package:cloud_firestore/cloud_firestore.dart';

class DreamModel {
  final String id;
  final String userId;
  final String dreamText;
  final String interpretation;
  final DateTime timestamp;
  final List<MessageModel> messages;

  DreamModel({
    required this.id,
    required this.userId,
    required this.dreamText,
    required this.interpretation,
    required this.timestamp,
    this.messages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dreamText': dreamText,
      'interpretation': interpretation,
      'timestamp': Timestamp.fromDate(timestamp),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory DreamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DreamModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      dreamText: data['dreamText'] ?? '',
      interpretation: data['interpretation'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      messages:
          (data['messages'] as List<dynamic>?)
              ?.map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DreamModel copyWith({
    String? id,
    String? userId,
    String? dreamText,
    String? interpretation,
    DateTime? timestamp,
    List<MessageModel>? messages,
  }) {
    return DreamModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dreamText: dreamText ?? this.dreamText,
      interpretation: interpretation ?? this.interpretation,
      timestamp: timestamp ?? this.timestamp,
      messages: messages ?? this.messages,
    );
  }
}

class MessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
