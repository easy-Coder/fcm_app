import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:notification_app/main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.token});

  final String? token;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController titleController;
  late final TextEditingController messageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final message = ref.read(messageProvider);
    titleController = TextEditingController();
    messageController = TextEditingController();
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Future.delayed(const Duration(milliseconds: 1000), () async {
          navigatorKey.currentState!
              .pushNamed('/second', arguments: message.notification!.body);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: "Message",
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendPushMessage();
                  },
                  child: const Text("Send Now"),
                ),
                const SizedBox(width: 4,),
                ElevatedButton(
                  onPressed: () {
                    sendDelayedPushMessage();
                  },
                  child: const Text("Send in 10 seconds"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  sendPushMessage() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();

    sendRequest(title, message);
  }

  sendDelayedPushMessage() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();

    await Future.delayed(const Duration(seconds: 10), () => sendRequest(title, message));
  }

  sendRequest(String title, String message) async {
    
      try {
        await http.post(
          Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            'Content-Type': "application/json",
            'Authorization':
                "key=AAAA0ESF41Y:APA91bEQeGVPVtQcEAwvEwLIZDYfTXXAnbweEfDzjGUbs0WK0zX0C6hYpa5kRPpBdea00EqR7zc_NvN0ZUuy0B64LXEpQEWyirSFxBM4XYln229n5gsEkqgWIKMmOursEOkwL7cp9z9M",
          },
          body: jsonEncode({
            'priority': 'high',
            'data': {
              'click_action': "NOTIFICATION_CLICK",
              'status': 'done',
              'body': message,
              'title': title
            },
            'notification': {
              'title': title,
              'body': message,
              'android_channel_id': 'notify1',
            },
            'to': widget.token!,
          }),
        );
      } catch (error) {
        debugPrint(error.toString());
      }
    
  }
}
