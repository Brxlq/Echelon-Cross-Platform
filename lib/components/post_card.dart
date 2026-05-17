import 'package:flutter/material.dart';

import '../models/models.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final Post post;

  ImageProvider<Object> _avatarImage() {
    if (post.profileImageUrl.startsWith('http://') ||
        post.profileImageUrl.startsWith('https://')) {
      return NetworkImage(post.profileImageUrl);
    }
    return AssetImage(post.profileImageUrl);
  }

  String _timeLabel() {
    if (post.timestamp == '0') {
      return 'Just now';
    }
    return '${post.timestamp} min ago';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: _avatarImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.comment,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_timeLabel(), style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
