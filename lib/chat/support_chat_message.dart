import 'package:cloud_firestore/cloud_firestore.dart';

class SupportChatMessage {
  SupportChatMessage({
    required this.senderId,
    required this.senderLabel,
    required this.text,
    required this.createdAt,
  });

  final String senderId;
  final String senderLabel;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'senderLabel': senderLabel,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory SupportChatMessage.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    DateTime createdAt = DateTime.now();
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is String) {
      createdAt = DateTime.tryParse(created) ?? DateTime.now();
    }
    return SupportChatMessage(
      senderId: json['senderId'] as String? ?? '',
      senderLabel: json['senderLabel'] as String? ?? 'Member',
      text: json['text'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
