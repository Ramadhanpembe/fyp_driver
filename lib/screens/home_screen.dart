import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                // documentID = await firestoreManager.storeDriverLocation(position);
                // if (documentID.isNotEmpty) {
                //   log('location saved to the database');
                //   log('documentID: $documentID');
                // }
              },
              child: const Text('No usage'),
            ),
            FilledButton(
              onPressed: () {
                // firestoreManager.getRouteNames();
                // log('Routes acquired successfully!');
              },
              child: const Text('No use'),
            ),
          ],
        ),
      ),
    );
  }
}
