import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_firebase/models/user.model.dart';
import 'package:tutorial_firebase/services/database.service.dart';

//provider to control friendships related actions
class FriendshipsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = false;
  // bool _isDataLoading = false;
  bool get isLoading => _isLoading;
  // bool get isDataLoading => _isDataLoading;

  int _friendshipRequestsCount = 0;

  int get friendshipRequestsCount => _friendshipRequestsCount;

  Future<List<UserModel>> fetchFriendshipRequests(
      User user, String friendshipStatus) async {
    List<UserModel> friendshipRequests = [];

    try {
      friendshipRequests =
          await _databaseService.getFriendList(user.uid, friendshipStatus);
      _friendshipRequestsCount = friendshipRequests.length;
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
    return friendshipRequests;
  }

  Future<List<UserModel>> fetchFriendList(User user) async {
    List<UserModel> friends = [];

    try {
      friends = await _databaseService.getFriendList(user.uid, 'accepted');
    } catch (e) {
      throw Exception(e);
    }
    return friends;
  }

  Future<void> declineRequest(User user, UserModel friend) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _databaseService.declineFriendshipRequest(user, friend);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e);
    }
  }

  Future<void> acceptRequest(User user, UserModel friend) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _databaseService.acceptFriendshipRequest(user, friend);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e);
    }
  }
}
