import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fyp_driver/data/resources.dart';
import 'package:fyp_driver/models/driver_login.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  late LocationSettings _locationSettings;

  LocationManager() {
    _init();
  }
  void _init() async {
    isPermissionGranted = await _requestLocationPermission();
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location service is disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission is denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission is permanently denied, we cannot request permission');
    }
    return true;
  }

  Future<Position?> getDriverCurrentLocation() async {
    if (!isPermissionGranted) return null;
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void listenForDriverPositionPeriodically(DriverLogin login) async {
    if (androidInfo.version.sdkInt <= 28 || !isPermissionGranted) return;
    Position? position = await getDriverCurrentLocation();
    if (position == null) return;
    await firestoreManager.updateDriverLocation(login, position);
  }

  void listenForLocationUpdates(DriverLogin login) async {
    if (!isPermissionGranted) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Running in the background',
          notificationText: 'PMS will receive your location updates even if you are not using it',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 0,
        showBackgroundLocationIndicator: true,
      );
    } else {
      _locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }
    positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
      (Position position) {
        firestoreManager.updateDriverLocation(login, position);
      },
      cancelOnError: true,
    );
  }
}
