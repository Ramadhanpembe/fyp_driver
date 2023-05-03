class DriverLocation {
  const DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
  });
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final String timestamp;
}
