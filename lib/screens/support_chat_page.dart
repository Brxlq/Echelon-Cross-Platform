import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../chat/support_chat_manager.dart';
import '../chat/support_chat_message.dart';
import '../chat/support_chat_repository.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  late final SupportChatManager _manager;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _manager = SupportChatManager(_createRepository());
  }

  SupportChatRepository _createRepository() {
    try {
      return FirestoreSupportChatRepository();
    } catch (_) {
      return InMemorySupportChatRepository();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Support Chat')),
      body: AnimatedBuilder(
        animation: _manager,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<SupportChatMessage>>(
                  stream: _manager.messageStream,
                  initialData: const [],
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? const [];
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('No messages yet. Start the conversation.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Card(
                          child: ListTile(
                            title: Text(message.senderLabel),
                            subtitle: Text(message.text),
                            trailing: Text(
                              DateFormat('HH:mm').format(message.createdAt),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_manager.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _manager.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: _submit,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _manager.sending
                            ? null
                            : () => _submit(_controller.text),
                        icon: _manager.sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(String value) async {
    await _manager.send(value);
    _controller.clear();
  }
}
