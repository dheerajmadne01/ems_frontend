import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  /// Request location permission if not granted
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services in settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please grant location permission to punch in/out.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable location permission from app settings.',
      );
    }

    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Get current position with high accuracy
  /// Automatically requests permission if needed
  Future<Position> getCurrentPosition() async {
    // First check and request permission
    await requestLocationPermission();
    
    // Get current position with high accuracy
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }
}


