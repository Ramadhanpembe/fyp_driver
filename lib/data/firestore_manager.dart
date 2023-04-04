import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_driver/models/driver_info.dart';
import 'package:fyp_driver/models/driver_login.dart';
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

  // works perfectly!
  void storeDriverLocations() async {
    for (var location in _locationsMap) {
      await _db.collection('locations').add(location);
    }
  }

  // works perfectly!
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

  // works perfectly!
  Future<bool> authenticateDriver(String phone, String password) async {
    bool doesExist = false;
    await _db.collection('drivers').get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        if (docSnapshot['login']['phone'] == phone &&
            docSnapshot['login']['password'] == password) {
          doesExist = true;
        }
      }
    });
    return doesExist;
  }

  // This method was meant to work with position stream which unfortunately doesn't work yet
  Future<bool> updateDriverLocation(DriverLogin login, Position position) async {
    String documentID = '';
    await _db.collection('drivers').get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        if (docSnapshot['login']['phone'] == login.phone &&
            docSnapshot['login']['password'] == login.password) {
          if (docSnapshot['location']['latitude'] == position.latitude &&
              docSnapshot['location']['longitude'] == position.longitude) {
            return false;
          }
          documentID = docSnapshot.id;
        }
      }
    });
    if (documentID.isNotEmpty) {
      await _db.collection('drivers').doc(documentID).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
        }
      });
      return true;
    }

    log('------------------------update method is reached!!!!');
    return false;
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
