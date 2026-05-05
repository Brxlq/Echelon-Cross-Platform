import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yummy/chat/support_chat_message.dart';

void main() {
  test('message json roundtrip keeps fields', () {
    final message = SupportChatMessage(
      senderId: 'u1',
      senderLabel: 'Member',
      text: 'Need help',
      createdAt: DateTime(2026, 1, 2, 12, 0),
    );

    final json = message.toJson();
    expect(json['createdAt'], isA<Timestamp>());

    final parsed = SupportChatMessage.fromJson(json);
    expect(parsed.senderId, 'u1');
    expect(parsed.senderLabel, 'Member');
    expect(parsed.text, 'Need help');
  });
}
