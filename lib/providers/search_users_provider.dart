import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_firebase/models/user.model.dart';
import 'package:tutorial_firebase/services/database.service.dart';

class SearchUsersProvider extends ChangeNotifier {
  UserModel? _foundUser;
  final DatabaseService _databaseService = DatabaseService();
  String? errorMsg;

  UserModel? get foundUser => _foundUser;
  bool get isFriend => _isFriend;
  bool get isFriendshipRequested => _isFriendshipRequested;

  bool loading = false;
  bool _isFriend = false;
  bool _isFriendshipRequested = false;

  void peformSearch(User currentUser, String email) async {
    loading = true;
    notifyListeners();

    try {
      final user = await _databaseService.findUser(email);
      if (user != null) {
        _isFriend =
            await _databaseService.checkIfUserIsFriend(currentUser, user);
        _isFriendshipRequested = await _databaseService
            .checkIfFriendshipRequested(currentUser, user);
        notifyListeners();
        _foundUser = user;
        errorMsg = null;
        loading = false;
        notifyListeners();
      }
    } catch (e) {
      log("E: $e");
      errorMsg = e.toString();
      loading = false;
      notifyListeners();
    }
  }

  Future<void> sendFriendShipRequest(User sender, UserModel receiver) async {
    await _databaseService.sendFriendshipRequestToDB(sender, receiver);
    _isFriendshipRequested =
        await _databaseService.checkIfFriendshipRequested(sender, receiver);
    notifyListeners();
  }

  void clear() {
    _foundUser = null;
    errorMsg = null;
  }
}
