import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_driver/data/notifications_manager.dart';
import 'package:fyp_driver/firebase_options.dart';
import 'package:fyp_driver/screens/login_screen.dart';

import 'data/firestore_manager.dart';
import 'data/location_manager.dart';
import 'data/resources.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  androidInfo = await deviceInfoPlugin.androidInfo;
  NotificationsManager.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _init() {
    firestoreManager = FirestoreManager();
    locationManager = LocationManager();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PMS Driver App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Colors.transparent,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
