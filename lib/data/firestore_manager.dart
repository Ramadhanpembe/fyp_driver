import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_driver/models/driver_info.dart';
import 'package:fyp_driver/models/driver_route.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/sample_data.dart';

class FirestoreManager {
  late FirebaseFirestore _db;
  List<Map<String, dynamic>> _locationsMap = [];
  FirestoreManager() {
    _init();
  }

  void _init() {
    _db = FirebaseFirestore.instance;
    _locationsMap = getMapFromList(locationsList);
  }

  void storeDriverLocations() async {
    for (var location in _locationsMap) {
      await _db.collection('locations').add(location);
    }
  }

  // Future<String> storeDriverLocation(Position? position) async {
  //   if (position != null) {
  //     String documentID = '';
  //     await _db.collection('locations').add({
  //       'latitude': position.latitude,
  //       'longitude': position.longitude,
  //       'speed': position.speed,
  //       'accuracy': position.accuracy,
  //     }).then((reference) {
  //       documentID = reference.id;
  //     });
  //     return documentID;
  //   }
  //   return Future.error('Null Position');
  // }

  Future<String> storeDriverInfo(Position? position, DriverInfo info) async {
    if (position != null) {
      String documentID = '';
      await _db.collection('drivers').add({
        'username': info.username,
        'login': {
          'phone': info.login.phone,
          'password': info.login.password,
        },
        'route': {
          'from_terminal': info.route.fromTerminal,
          'to_terminal': info.route.toTerminal,
        },
        'location': {
          'latitude': info.location.latitude,
          'longitude': info.location.longitude,
          'speed': info.location.speed,
          'accuracy': info.location.accuracy,
        },
      }).then((reference) {
        documentID = reference.id;
        log('------------------DocumentID: $documentID----------}');
      });
      return documentID;
    }
    return Future.error('Location cannot be determined');
  }

  void updateDriverLocation(String documentID, Position position) async {
    await _db.collection('locations').doc(documentID).update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'speed': position.speed,
      'accuracy': position.accuracy,
    });
  }

  // This works perfectly!
  Future<List<DriverRoute>> getRouteNames() async {
    List<DriverRoute> routes = [];
    await _db.collection('routes').get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        routes.add(DriverRoute(
            fromTerminal: docSnapshot.get('from_terminal'),
            toTerminal: docSnapshot.get('to_terminal')));
      }
    });
    for (var route in routes) {
      log('fromTerminal: ${route.fromTerminal}');
      log('toTerminal: ${route.toTerminal}');
    }
    return routes;
  }
}
