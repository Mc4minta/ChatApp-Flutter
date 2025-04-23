import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show avatar only if it's the first in sequence AND not the sender
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: isFirstInSequence
                  ? CircleAvatar(
                      backgroundImage: userImage != null
                          ? NetworkImage(userImage!)
                          : const AssetImage('assets/images/default-profile.jpg')
                              as ImageProvider,
                      backgroundColor: theme.colorScheme.primary.withAlpha(180),
                      radius: 20,
                    )
                  : const SizedBox(width: 40), // Fake avatar space for alignment
            ),
          // username and chat bubble
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (isFirstInSequence && username != null)
                // sender username
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    username!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              // sender message bubble
              Container(
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.grey[300]
                      : theme.colorScheme.secondary.withAlpha(200),
                  borderRadius: BorderRadius.only(
                    topLeft: !isMe && isFirstInSequence
                        ? Radius.zero
                        : const Radius.circular(12),
                    topRight: isMe && isFirstInSequence
                        ? Radius.zero
                        : const Radius.circular(12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                ),
                constraints: const BoxConstraints(maxWidth: 250),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  message,
                  style: TextStyle(
                    height: 1.3,
                    color:
                        isMe ? Colors.black87 : theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
          // Avatar on the right for "me" (if wanted)
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: isFirstInSequence
                  ? CircleAvatar(
                      backgroundImage: userImage != null
                          ? NetworkImage(userImage!)
                          : const AssetImage('assets/images/default-profile.jpg')
                              as ImageProvider,
                      backgroundColor: theme.colorScheme.primary.withAlpha(180),
                      radius: 20,
                    )
                  : const SizedBox(width: 40), // Fake avatar space for alignment
            ),
        ],
      ),
    );
  }
}