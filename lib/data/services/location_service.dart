import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../core/utils/logger.dart';

/// A place name resolved from coordinates (FIX-7.13).
class ResolvedPlace {
  final String? city;
  final String? formattedAddress;

  const ResolvedPlace({this.city, this.formattedAddress});
}

class LocationService {
  // geocoding v5 moved from top-level free functions to instance methods on
  // this class — pubspec.yaml pinned `geocoding: any`, which resolved to 5.0.0.
  // Constructed lazily, inside resolvePlace()'s try block below, NOT as a
  // field here: Geocoding()'s constructor does a synchronous null-check
  // against the platform plugin registration, which throws in any context
  // without a real platform channel (widget tests, or LocationService built
  // before plugins finish registering) — a field initializer would crash
  // eagerly, outside resolvePlace()'s own "never throw, return null" contract.
  Geocoding? _geocoding;

  /// Request permissions and get the current user location.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// True when location is already usable (service on + permission granted),
  /// WITHOUT prompting the user. Lets screens centre on the user silently
  /// when they've already agreed, and ask only on an explicit action.
  Future<bool> hasPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Opens the OS screen where the user can re-enable location / permission.
  Future<void> openSettings() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }

  /// Calculates a geohash for a given location.
  String getGeohash(double latitude, double longitude) {
    return GeoFirePoint(GeoPoint(latitude, longitude)).geohash;
  }

  /// Reverse-geocodes coordinates into a city + human-readable address
  /// (FIX-7.13). Returns `null` when the platform geocoder has nothing for
  /// these coordinates or is unavailable (no Play Services, no network) —
  /// callers must treat this as "couldn't resolve", never as an error worth
  /// blocking on, since the owner can always type the address by hand.
  Future<ResolvedPlace?> resolvePlace(double latitude, double longitude) async {
    try {
      _geocoding ??= Geocoding();
      final placemarks = await _geocoding!.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;

      // `locality` is the city on most providers, but it comes back empty in
      // plenty of regions — fall back through the wider administrative names
      // rather than storing an empty city.
      final city = [p.locality, p.subAdministrativeArea, p.administrativeArea]
          .firstWhere(
            (v) => v != null && v.trim().isNotEmpty,
            orElse: () => null,
          )
          ?.trim();

      final address = [p.street, p.subLocality, p.locality, p.administrativeArea]
          .where((v) => v != null && v.trim().isNotEmpty)
          .map((v) => v!.trim())
          .toSet() // the same name often repeats across these fields
          .join(', ');

      return ResolvedPlace(
        city: city,
        formattedAddress: address.isEmpty ? null : address,
      );
    } catch (e) {
      Logger.e('Reverse geocoding failed for $latitude,$longitude: $e');
      return null;
    }
  }
}
