// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electech/controller/firebase_data_controller.dart';
import 'package:electech/provider/timer_provider.dart';
import 'package:electech/screens/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
AndroidNotificationChannel? channel;

const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();
FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

showNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;

  AndroidNotification? androidNotification = message.notification?.android;

  if (message.notification != null && androidNotification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(
        // iOS: DarwinNotificationDetails(
        //   presentSound: true,
        //   presentAlert: true,
        //   presentBadge: true,
        //   subtitle: message.notification!.body!,
        // ),
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          icon: '@mipmap/ic_launcher',
          priority: Priority.high,
          importance: Importance.high,
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => Get.put(FirebaseDataController()));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //log("Foreground message: ${message.notification?.title}");

    showNotification(message);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    importance: Importance.high,
  );
  var intilizationSettignAndroid = const AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  var initializtionSettings = InitializationSettings(
    android: intilizationSettignAndroid,
    //  iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin.initialize(
    initializtionSettings,
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Timeprovider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> savingFcmToken() async {
    String token = (await FirebaseMessaging.instance.getToken())!;
    await storeToken(token);
  }

  final _firebaseInstance = FirebaseFirestore.instance.collection('FcmTokens');
  // to replace 'FcmTokens' with your desired collection name

  Future<void> storeToken(String token) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance
          .where('fcmT', isEqualTo: token)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Token already exists in Firestore
      } else {
        // Token doesn't exist, save it
        String randomId = _firebaseInstance.doc().id;
        await _firebaseInstance.doc(randomId).set({'fcmT': token});
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electech',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffcfe5f3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAABBCC),
          primary: const Color(0xFF01579b),
          secondary: Colors.blue.withOpacity(0.25),
          tertiary: const Color(0xff050327),
        ),
        useMaterial3: true,
      ),
      home: const Auth(),
    );

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   //home: Auth(),
    //   routes: {
    //     "/": (context) => const SplashScreen(),
    //     "HomeScreen": (context) => HomePage(),
    //     "signupScreen": (context) => SignupScreenn(),
    //     "loginScreen": (context) => LoginScreen(),
    //   },
    // );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Electech',
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xffcfe5f3),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFFAABBCC),
//           primary: const Color(0xFF01579b),
//           secondary: Colors.blue.withOpacity(0.25),
//           tertiary: const Color(0xff050327),
//         ),
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }
