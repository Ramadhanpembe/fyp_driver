import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fyp_driver/data/resources.dart';
import 'package:fyp_driver/models/driver_login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.login});
  final DriverLogin login;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer? positionTimer;
  late Timer? notificationTimer;
  @override
  void initState() {
    locationManager.listenForLocationUpdates(widget.login);
    driverLoginNotifier.value = widget.login;
    log('############################${driverLoginNotifier.value.phone}');
    positionTimer = Timer.periodic(const Duration(seconds: 1),
        (timer) => locationManager.listenForDriverPositionPeriodically(widget.login));
    notificationTimer = Timer.periodic(const Duration(seconds: 3),
        (timer) => firestoreManager.listenForNotificationUpdates(widget.login.phone));
    super.initState();
  }

  @override
  void dispose() {
    positionTimer?.cancel();
    notificationTimer?.cancel();
    positionStream.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PMS Driver App'),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () async {
            // NotificationsManager.showNotification();
          },
          child: const Text('Show Notification'),
        ),
      ),
    );
  }
}
