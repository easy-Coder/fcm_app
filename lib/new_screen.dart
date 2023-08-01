import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_app/main.dart' show messageProvider;

class NewScreen extends ConsumerWidget {
  const NewScreen({super.key});

  // final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ModalRoute.of(context)!.settings.arguments;
    ref.invalidate(messageProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Push Notification"),
      ),
      body: Center(
        child: Text(message!.toString()),
      ),
    );
  }
}
