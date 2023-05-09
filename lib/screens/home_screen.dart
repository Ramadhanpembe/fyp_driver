import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    // this is intended to be used with firestoreManager only!
    driverLoginNotifier.value = widget.login;
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                color: Colors.grey[200],
                height: 50.0,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Icon(
                        Icons.history,
                        size: 24.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Your ride history',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: firestoreManager.responseStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const SizedBox(
                      height: 32.0,
                      width: 32.0,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.0,
                      ),
                    );
                  }
                  final QuerySnapshot querySnapshot = snapshot.data!;
                  final List<QueryDocumentSnapshot> driverDocs = querySnapshot.docs;
                  for (var driverDoc in driverDocs) {
                    if (driverDoc['login']['phone'] == widget.login.phone) {
                      final CollectionReference responseColRef =
                          driverDoc.reference.collection('responses');
                      return StreamBuilder(
                        stream: responseColRef.snapshots(),
                        builder: (context, responseSnapshot) {
                          if (responseSnapshot.connectionState == ConnectionState.waiting ||
                              responseSnapshot.data == null) {
                            return Container();
                          }
                          final QuerySnapshot responseQuerySnapshot = responseSnapshot.data!;
                          final List<QueryDocumentSnapshot> driverResponses =
                              responseQuerySnapshot.docs;
                          return Expanded(
                            child: Scrollbar(
                              child: ListView.builder(
                                itemCount: driverResponses.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: (index % 2) == 0 ? Colors.grey[100] : Colors.grey[200],
                                    child: ListTile(
                                      visualDensity: VisualDensity.compact,
                                      title: Text(_date(driverResponses[index]['timestamp'])),
                                      subtitle: Text(_time(driverResponses[index]['timestamp'])),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: SizedBox(
                                          width: 70.0,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              driverResponses[index]['is_accepted']
                                                  ? const Icon(
                                                      Icons.check_box,
                                                      size: 12.0,
                                                      color: Colors.green,
                                                    )
                                                  : const Icon(
                                                      Icons.cancel,
                                                      size: 12.0,
                                                      color: Colors.red,
                                                    ),
                                              driverResponses[index]['is_accepted']
                                                  ? const Text(
                                                      'accepted',
                                                      style: TextStyle(
                                                          fontSize: 12.0, color: Colors.green),
                                                    )
                                                  : const Text(
                                                      'rejected',
                                                      style: TextStyle(
                                                          fontSize: 12.0, color: Colors.red),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _date(String timestamp) {
    final DateTime date = DateTime.parse(timestamp);
    final String dayString = date.day.toString();
    final String day = dayString.characters.length <= 1 ? dayString.padLeft(2, '0') : dayString;
    final String monthString = date.month.toString();
    final String month =
        monthString.characters.length <= 1 ? monthString.padLeft(2, '0') : monthString;
    return '$day - $month - ${date.year}';
  }

  String _time(String timeStamp) {
    final DateTime time = DateTime.parse(timeStamp);
    final String hourString = time.hour.toString();
    final String hour = hourString.characters.length <= 1 ? hourString.padLeft(2, '0') : hourString;
    final String minuteString = time.minute.toString();
    final String minute =
        minuteString.characters.length <= 1 ? minuteString.padLeft(2, '0') : minuteString;
    return 'Time: $hour:$minute';
  }
}
