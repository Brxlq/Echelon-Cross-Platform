import 'package:flutter/foundation.dart';

import 'support_chat_message.dart';
import 'support_chat_repository.dart';

class SupportChatManager extends ChangeNotifier {
  SupportChatManager(this._repository);

  final SupportChatRepository _repository;

  bool _sending = false;
  String? _error;

  bool get sending => _sending;
  String? get error => _error;
  Stream<List<SupportChatMessage>> get messageStream => _repository.watchMessages();

  Future<void> send(String text) async {
    _sending = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.sendMessage(text);
    } catch (e) {
      _error = e.toString();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
