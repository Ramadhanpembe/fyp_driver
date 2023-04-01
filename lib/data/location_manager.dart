import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:fyp_driver/data/resources.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  late LocationSettings _locationSettings;

  LocationManager() {
    _init();
  }
  void _init() async {
    isPermissionGranted = await _requestLocationPermission();
    _listenForLocationUpdates();
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
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  void _listenForLocationUpdates() async {
    if (!isPermissionGranted) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        forceLocationManager: true,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Running in the background',
          notificationText: 'PMS will receive your location updates even if you are not using it',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 0,
        showBackgroundLocationIndicator: true,
      );
    } else {
      _locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      );
    }
    Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
      (Position position) {
        if (documentID.isNotEmpty) {
          log(documentID);
          log(position.toString());
          firestoreManager.updateDriverLocation(documentID, position);
          log('Document is updated successfully!');
        }
        log('latest_latitude: ${position.latitude}');
        log('latest_longitude: ${position.longitude}');
        log('Can we reach this statement?');
      },
      cancelOnError: true,
    );
  }
}
