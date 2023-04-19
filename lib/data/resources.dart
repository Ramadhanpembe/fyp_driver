import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_login.dart';
import 'firestore_manager.dart';
import 'location_manager.dart';

late final FirestoreManager firestoreManager;
late final LocationManager locationManager;
bool isPermissionGranted = false;
late final StreamSubscription<Position> positionStream;
late final AndroidDeviceInfo androidInfo;
final driverLoginNotifier = ValueNotifier<DriverLogin>(const DriverLogin(phone: '', password: ''));
final messageIDNotifier = ValueNotifier<String>('');
