import 'package:flutter/material.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
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
          if (!isMe)
            CircleAvatar(
              backgroundImage: userImage != null
                ? NetworkImage(userImage!)
                : const AssetImage('assets/images/default-profile.jpg'),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 20,
            ),
          // Message Column
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (isFirstInSequence && username != null)
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
              Container(
                decoration: BoxDecoration(
                  color:
                      isMe
                          ? Colors.grey[300]
                          : theme.colorScheme.secondary.withAlpha(200),
                  borderRadius: BorderRadius.only(
                    topLeft:
                        !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                    topRight:
                        isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                ),
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
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

          // Avatar on the right (if it's my message)
          if (isMe && userImage != null) const SizedBox(width: 12),
          if (isMe)
            CircleAvatar(
              backgroundImage:
                  userImage != null
                      ? NetworkImage(userImage!)
                      : const AssetImage('assets/images/default-profile.jpg'),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 20,
            ),
        ],
      ),
    );
  }
}
