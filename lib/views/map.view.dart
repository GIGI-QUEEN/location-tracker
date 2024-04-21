import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tutorial_firebase/providers/location_provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LocationProvider _locationProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Marker> markers = {};
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _getUserLocation();
    _populateMarkers();
  }

  Future<void> _getUserLocation() async {
    final location = _locationProvider.getMyLocation();
    setState(() {
      userLocation = location;
    });
  }

  void _populateMarkers() {
    _firestore
        .collection('users')
        .snapshots()
        .listen((QuerySnapshot userSnapshot) {
      final friendsLocations = _locationProvider.getFriendsLocations();
      final friendsEmails = _locationProvider.getFriendsEmails();
      Set<Marker> tempMarkers = {};

      friendsLocations.forEach((friendId, location) {
        tempMarkers.add(Marker(
          markerId: MarkerId(friendId),
          position: location,
          infoWindow: InfoWindow(title: friendsEmails[friendId]),
        ));
      });

      if (mounted) {
        setState(() {
          markers = tempMarkers;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: userLocation ?? const LatLng(0.0, 0.0),
          zoom: 10,
        ),
        markers: markers,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        padding: const EdgeInsets.only(top: 550.0),
      ),
    );
  }
}
