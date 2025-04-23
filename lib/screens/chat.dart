import 'package:chatapp/widgets/chat_message.dart';
import 'package:chatapp/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');

    // final token = await fcm.getToken();
    // print(token); // push noti to then token in database
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 204, 255), // Color.fromARGB(255, 121, 121, 121),
        // title: Text('FlutterChat'),
        title: Text(
          'FlutterChat',
          style: TextStyle(color: Color.fromARGB(255, 0, 69, 100),fontWeight: FontWeight.w900),
        ), //Image.asset('assets/Logo-nobg.jpg', fit: BoxFit.cover,width: 200,),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: Icon(Icons.exit_to_app,color: Color.fromARGB(255, 0, 69, 100),),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: Column(
        children: const [Expanded(child: ChatMessages()), NewMessage()],
      ),
    );
  }
}