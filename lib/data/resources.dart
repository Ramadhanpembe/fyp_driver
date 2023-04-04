import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'firestore_manager.dart';
import 'location_manager.dart';

late final FirestoreManager firestoreManager;
late final LocationManager locationManager;
bool isPermissionGranted = false;
late final StreamSubscription<Position> positionStream;
