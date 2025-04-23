import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    
    _messageController.clear();
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser!;
    final userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'profileImageUrl': userData.data()!['profileImageUrl'],
    });

  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color.fromARGB(255, 0, 69, 100),
          height: 0.5,
        ),
        Container(
          padding: const EdgeInsets.only(left: 5, right: 1, bottom: 14, top: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    labelText: 'Send a message...',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 69, 100)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ), // Rounded corners
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 69, 100),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                color: Color.fromARGB(255, 0, 204, 255),
                icon: const Icon(Icons.send),
                onPressed: () {
                  _submitMessage();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
