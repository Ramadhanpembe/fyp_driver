import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fyp_driver/data/resources.dart';
import 'package:fyp_driver/models/driver_login.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.login});
  final DriverLogin login;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer? timer;
  @override
  void initState() {
    locationManager.listenForLocationUpdates(widget.login);
    timer = Timer.periodic(const Duration(seconds: 1),
        (timer) => locationManager.listenForDriverPositionPeriodically(widget.login));
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
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
        child: StreamBuilder<Position>(
          stream: Geolocator.getPositionStream(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0)),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Permission Granted? $isPermissionGranted Null Data!',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 32.0, color: Colors.indigo),
                  ),
                  FilledButton(
                    onPressed: () async {
                      /// These stuff will need to be deleted as they technically don't work
                      Position? position = await locationManager.getDriverCurrentLocation();
                      if (position != null) {
                        log('___current_latitude: ${position.latitude}');
                        log('___current_longitude: ${position.longitude}');
                      }

                      Geolocator.getPositionStream().listen((Position? position) {
                        log('___stream_latitude: ${position?.latitude}');
                        log('___stream_longitude: ${position?.longitude}');
                      });
                    },
                    child: const Text('Get Current Position'),
                  ),
                ],
              );
            }
            Position position = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('latitude: ${position.latitude}'),
                Text('longitude: ${position.longitude}'),
                Text('accuracy: ${position.accuracy}'),
                Text('speed: ${position.speed}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
