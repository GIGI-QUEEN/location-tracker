import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Map<String, LatLng> friendsLocations = {};
Map<String, String> _friendsEmails = {};
late LatLng _myLocation;

class LocationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<DocumentSnapshot>? _friendsLocationsSubscription;
  final Map<String, StreamSubscription<DocumentSnapshot>> _friendSubscriptions =
      {};
  List<String> userFriendsIds = [];

  Map<String, LatLng> getFriendsLocations() {
    return friendsLocations;
  }

  Map<String, String> getFriendsEmails() {
    return _friendsEmails;
  }

  void setMyLocation(LatLng location) {
    _myLocation = location;
  }

  LatLng getMyLocation() {
    return _myLocation;
  }

  void startFriendsListening(String userId) async {
    _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((userSnapshot) {
      if (userSnapshot.exists) {
        var previousFriendsIds = userFriendsIds;
        final friends = userSnapshot.data()?['friends'] as Map<String, dynamic>;

        if (friends.isNotEmpty) {
          userFriendsIds = friends.keys.toList();
          if (previousFriendsIds == userFriendsIds) {
          } else {
            final addedFriends = userFriendsIds
                .where((friendId) => !previousFriendsIds.contains(friendId))
                .toList();

            final removedFriends = previousFriendsIds
                .where((friendId) => !userFriendsIds.contains(friendId))
                .toList();

            if (removedFriends.isNotEmpty) {
              for (var friend in removedFriends) {
                stopFriendLocationListening(friend);
                friendsLocations.remove(friend);
                _friendsEmails.remove(friend);
                notifyListeners();
              }
            }

            if (addedFriends.isNotEmpty) {
              for (var friend in addedFriends) {
                startFriendLocationListening(friend);
                addFriendEmail(friend);
                notifyListeners();
              }
            }
          }
        } else {
          // if there are no users in 'friends' field
          userFriendsIds = [];
          friendsLocations.clear();
          _friendsEmails.clear();
          _friendSubscriptions.clear();
          notifyListeners();
        }
      }
    });
  }

  void startFriendLocationListening(friendId) async {
    _friendSubscriptions[friendId] = _firestore
        .collection('users')
        .doc(friendId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var location = snapshot.data()?['location'] as GeoPoint?;

        if (location != null) {
          friendsLocations[friendId] =
              LatLng(location.latitude, location.longitude);
        }
      } else {
        stopFriendLocationListening(friendId);
      }
    });
    notifyListeners();
  }

  void stopFriendLocationListening(String friendId) {
    _friendSubscriptions[friendId]?.cancel();
    _friendSubscriptions.remove(friendId);
  }

  Future<void> updateLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    final DocumentReference userDocRef =
        _firestore.collection('users').doc(userId);

    await userDocRef.update({
      'location': GeoPoint(
        latitude,
        longitude,
      ),
    });
  }

  Future<void> addFriendEmail(String friendId) async {
    DocumentSnapshot friendSnapshot =
        await _firestore.collection('users').doc(friendId).get();

    if (friendSnapshot.exists) {
      var data = friendSnapshot.data();
      if (data is Map<String, dynamic>) {
        var friendEmail = data['email'] as String?;
        if (friendEmail != null) {
          _friendsEmails[friendId] = friendEmail;
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _friendsLocationsSubscription?.cancel();
    super.dispose();
  }

  Map<String, String> get friendsEmails => _friendsEmails;
}
