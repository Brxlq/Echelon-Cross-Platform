import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yummy/chat/support_chat_manager.dart';
import 'package:yummy/chat/support_chat_message.dart';
import 'package:yummy/chat/support_chat_repository.dart';

class _FakeSupportChatRepository implements SupportChatRepository {
  final List<SupportChatMessage> _messages = [];
  final StreamController<List<SupportChatMessage>> _controller =
      StreamController<List<SupportChatMessage>>.broadcast();

  @override
  Future<void> sendMessage(String text) async {
    _messages.add(
      SupportChatMessage(
        senderId: 'u1',
        senderLabel: 'Member',
        text: text,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    _controller.add(List.unmodifiable(_messages));
  }

  @override
  Stream<List<SupportChatMessage>> watchMessages() {
    Future<void>.microtask(() {
      if (!_controller.isClosed) {
        _controller.add(List.unmodifiable(_messages));
      }
    });
    return _controller.stream;
  }
}

void main() {
  test('manager sends message and emits stream data', () async {
    final repository = _FakeSupportChatRepository();
    final manager = SupportChatManager(repository);

    expect(manager.sending, isFalse);
    final messageFuture = manager.messageStream.first;
    await manager.send('hello');
    expect(manager.sending, isFalse);
    expect(manager.error, isNull);

    final messages = await messageFuture;
    expect(messages.length, 1);
    expect(messages.first.text, 'hello');
  });
}
