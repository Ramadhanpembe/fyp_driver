import 'package:fyp_driver/models/driver_location.dart';
import 'package:fyp_driver/models/driver_login.dart';
import 'package:fyp_driver/models/driver_route.dart';

class DriverInfo {
  const DriverInfo(
      {required this.username, required this.login, required this.location, required this.route});
  final String username;
  final DriverLogin login;
  final DriverLocation location;
  final DriverRoute route;
}
