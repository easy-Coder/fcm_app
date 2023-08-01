// import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notification_app/home_screen.dart';
import 'package:notification_app/new_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final messageProvider = Provider<RemoteMessage?>((ref) {
  throw UnimplementedError();
});

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  debugPrint("background message: ${message.notification!.title}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const androidChannel = AndroidNotificationChannel('notify1', 'notify',
    importance: Importance.high, playSound: true);

void requestPermission() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission();
  await messaging.setForegroundNotificationPresentationOptions(
      alert: true, sound: true);

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  } else {
    debugPrint("Not authorized");
  }
}

void initLocalNotification() {
  const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
  const iosInit = DarwinInitializationSettings();
  const initializedSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);
  flutterLocalNotificationsPlugin.initialize(
    initializedSettings,
    onDidReceiveNotificationResponse: (details) {
      debugPrint("Received");

      if (details.payload != null) {
        debugPrint("Pushing");
        navigatorKey.currentState!
            .pushNamed('/second', arguments: details.payload);
      }
    },
  );
  FirebaseMessaging.onMessage.listen((message) async {
    final BigTextStyleInformation info = BigTextStyleInformation(
        message.notification!.body.toString(),
        contentTitle: message.notification!.title.toString(),
        htmlFormatBigText: true,
        htmlFormatContentTitle: true);
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      styleInformation: info,
      importance: androidChannel.importance,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: androidChannel.playSound,
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: message.data['title'],
    );
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.notification!.body != null) {
      navigatorKey.currentState!
          .pushNamed('/second', arguments: message.notification!.body);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final message = await FirebaseMessaging.instance.getInitialMessage();

  final container = ProviderContainer(
    overrides: [
      messageProvider.overrideWithValue(message),
    ],
  );
  requestPermission();
  initLocalNotification();
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  runApp(
      UncontrolledProviderScope(container: container, child: const MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  String? mtoken;

  void getToken() async {
    final token = await FirebaseMessaging.instance.getToken();

    setState(() {
      mtoken = token;
      debugPrint("Token: $mtoken");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final message = ref.read(messageProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 1000), () async {
          await Navigator.of(context).pushNamed('/');
        });
      }
    });
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => HomeScreen(
              token: mtoken,
            ),
        '/second': (context) => const NewScreen()
      },
    );
  }
}
