import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _latitudeKey = 'user_latitude';
  static const String _longitudeKey = 'user_longitude';
  static const String _addressKey = 'user_address';
  static const String _lastUpdatedKey = 'location_last_updated';

  /// Fetches current location and stores it in SharedPreferences
  /// Returns true if successful, false otherwise
  static Future<bool> fetchAndStoreLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied');
        return false;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      String address = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address =
              "${place.street}, ${place.locality}, ${place.administrativeArea}";
        }
      } catch (e) {
        print('Error getting address: $e');
        address = 'Address not available';
      }

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latitudeKey, position.latitude);
      await prefs.setDouble(_longitudeKey, position.longitude);
      await prefs.setString(_addressKey, address);
      await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());

      print('Location stored: $address (${position.latitude}, ${position.longitude})');
      return true;
    } catch (e) {
      print('Error fetching location: $e');
      return false;
    }
  }

  /// Gets stored latitude from SharedPreferences
  static Future<double?> getStoredLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_latitudeKey);
  }

  /// Gets stored longitude from SharedPreferences
  static Future<double?> getStoredLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_longitudeKey);
  }

  /// Gets stored address from SharedPreferences
  static Future<String?> getStoredAddress() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString(_addressKey));
    return prefs.getString(_addressKey);
  }

  /// Gets the last updated timestamp
  static Future<DateTime?> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastUpdatedKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// Gets all stored location data
  static Future<Map<String, dynamic>> getStoredLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'latitude': prefs.getDouble(_latitudeKey),
      'longitude': prefs.getDouble(_longitudeKey),
      'address': prefs.getString(_addressKey),
      'lastUpdated': prefs.getString(_lastUpdatedKey),
    };
  }

  /// Clears stored location data
  static Future<void> clearStoredLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_lastUpdatedKey);
  }
}
