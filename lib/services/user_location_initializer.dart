import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tutorial_firebase/providers/location_provider.dart';
import 'package:tutorial_firebase/services/database.service.dart';

Location location = Location();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final DatabaseService _databaseService = DatabaseService();
LocationProvider _locationProvider = LocationProvider();

Future<void> initUserLocation() async {
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  location.onLocationChanged.listen((LocationData currentLocation) {
    if (_firebaseAuth.currentUser != null) {
      final userId = _firebaseAuth.currentUser!.uid;
      _databaseService.updateLocation(
        userId,
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      _locationProvider.setMyLocation(LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      ));
    }
  });
}
