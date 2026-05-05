import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'support_chat_message.dart';

abstract class SupportChatRepository {
  Stream<List<SupportChatMessage>> watchMessages();
  Future<void> sendMessage(String text);
}

class FirestoreSupportChatRepository implements SupportChatRepository {
  FirestoreSupportChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('support_messages');

  Future<void> _ensureAuth() async {
    if (_auth.currentUser != null) {
      return;
    }
    await _auth.signInAnonymously();
  }

  @override
  Stream<List<SupportChatMessage>> watchMessages() async* {
    await _ensureAuth();
    yield* _messages
        .orderBy('createdAt', descending: false)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportChatMessage.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _ensureAuth();
    final user = _auth.currentUser;
    final message = SupportChatMessage(
      senderId: user?.uid ?? 'unknown',
      senderLabel: user?.email ?? 'Echelon Member',
      text: trimmed,
      createdAt: DateTime.now(),
    );
    await _messages.add(message.toJson());
  }
}

class InMemorySupportChatRepository implements SupportChatRepository {
  final List<SupportChatMessage> _messages = [];
  final StreamController<List<SupportChatMessage>> _controller =
      StreamController<List<SupportChatMessage>>.broadcast();

  @override
  Stream<List<SupportChatMessage>> watchMessages() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_messages));
    }
    return _controller.stream;
  }

  @override
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _messages.add(
      SupportChatMessage(
        senderId: 'local',
        senderLabel: 'Local Member',
        text: trimmed,
        createdAt: DateTime.now(),
      ),
    );
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_messages));
    }
  }
}
