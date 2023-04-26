import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_driver/data/notifications_manager.dart';
import 'package:fyp_driver/data/resources.dart';
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

  // We need to get real time responses from this stream and display them to a respective driver
  Stream<QuerySnapshot> responseStream() {
    return _db.collection('drivers').snapshots();
  }

  Future<bool> _driverExists(DriverInfo info) async {
    final CollectionReference driverColRef = _db.collection('drivers');
    final QuerySnapshot querySnapshot = await driverColRef.get();
    final List<QueryDocumentSnapshot> driverDocs = querySnapshot.docs;
    for (var driverDoc in driverDocs) {
      if (info.login.phone == driverDoc['login']['phone']) return true;
    }
    return false;
  }

  // works perfectly!
  Future<String> storeDriverInfo(Position? position, DriverInfo info) async {
    bool doesExist = await _driverExists(info);
    if (position != null && !doesExist) {
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
    return false;
  }

  Future<int> _getAllCurrentNotifications(String phone) async {
    int totalMessages = 0;
    final CollectionReference driverColRef = _db.collection('drivers');
    final QuerySnapshot querySnapshot = await driverColRef.get();
    final List<QueryDocumentSnapshot> driverDocs = querySnapshot.docs;
    for (var driverDoc in driverDocs) {
      if (driverDoc['login']['phone'] == phone) {
        final CollectionReference messageColRef = driverDoc.reference.collection('messages');
        final QuerySnapshot querySnapshot = await messageColRef.get();
        totalMessages = querySnapshot.docs.length;
      }
    }
    return totalMessages;
  }

  void listenForNotificationUpdates(String phone) async {
    final int totalCurrentMessages = await _getAllCurrentNotifications(phone);
    final CollectionReference driverColRef = _db.collection('drivers');
    final QuerySnapshot querySnapshot = await driverColRef.get();
    final List<QueryDocumentSnapshot> driverDocs = querySnapshot.docs;
    for (var driverDoc in driverDocs) {
      if (driverDoc['login']['phone'] == phone) {
        final CollectionReference messageColRef = driverDoc.reference.collection('messages');
        messageColRef.snapshots().listen((querySnapshot) {
          final List<QueryDocumentSnapshot> messageDocs = querySnapshot.docs;
          if (messageDocs.length == totalCurrentMessages + 1) {
            List<int> messageTimes = [];
            for (var messageDoc in messageDocs) {
              messageTimes.add(DateTime.parse(messageDoc['message_id']).millisecondsSinceEpoch);
            }
            messageTimes.sort();
            int latestTime = messageTimes.last;

            for (var messageDoc in messageDocs) {
              if (messageDoc['message_id'] ==
                  DateTime.fromMillisecondsSinceEpoch(latestTime).toString()) {
                messageIDNotifier.value = messageDoc['message_id'];
                NotificationsManager.showNotification(
                  title: messageDoc['title'],
                  body: messageDoc['body'],
                );
              }
            }
          }
        });
      }
    }
  }

  void saveResponse({bool isAccepted = false}) async {
    final CollectionReference driverColRef = _db.collection('drivers');
    final QuerySnapshot querySnapshot = await driverColRef.get();
    final List<QueryDocumentSnapshot> driverDocs = querySnapshot.docs;
    for (var driverDoc in driverDocs) {
      if (driverDoc['login']['phone'] == driverLoginNotifier.value.phone) {
        final CollectionReference responseColRef = driverDoc.reference.collection('responses');
        final DocumentReference responseID =
            responseColRef.doc('@${DateTime.now().millisecondsSinceEpoch}@');
        responseID.set({
          'message_id': messageIDNotifier.value,
          'timestamp': DateTime.now().toString(),
          'is_accepted': isAccepted,
        });
      }
    }
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
    return routes;
  }
}
