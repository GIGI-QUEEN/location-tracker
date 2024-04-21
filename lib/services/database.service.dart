// ignore_for_file: constant_identifier_names

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tutorial_firebase/models/user.model.dart';

class DatabaseService {
  final _database = FirebaseFirestore.instance;

  static const USERS_COLLECTION_PATH = 'users';
  static const FRIENDSHIPS_COLLECTION_PATH = 'friendships';
  static const FRIENDLIST_PATH = 'friendList';

  Future<void> addUserToDB(User user) async {
    try {
      await _database.collection(USERS_COLLECTION_PATH).doc(user.uid).set({
        "uid": user.uid,
        "email": user.email,
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendFriendshipRequestToDB(
      User sender, UserModel receiver) async {
    WriteBatch batch = _database.batch();
    final CollectionReference friendshipsCollection =
        _database.collection(FRIENDSHIPS_COLLECTION_PATH);

    DocumentReference senderDocReference =
        friendshipsCollection.doc(sender.uid);

    batch.set(
      senderDocReference,
      {
        FRIENDLIST_PATH: {receiver.uid: 'pending'}
      },
      SetOptions(merge: true),
    );

    DocumentReference receiverDocReference =
        friendshipsCollection.doc(receiver.uid);
    batch.set(
      receiverDocReference,
      {
        FRIENDLIST_PATH: {sender.uid: 'requested'}
      },
      SetOptions(merge: true),
    );

    try {
      await batch.commit();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UserModel?> findUser(String email) async {
    UserModel user;
    QuerySnapshot querySnapshot = await _database
        .collection(USERS_COLLECTION_PATH)
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // User found, process the result
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        //  log('User found: ${doc.data()}');
        user =
            UserModel.fromMap(Map<String, dynamic>.from(doc.data() as dynamic));
        return user;
      }
    } else {
      // User not found
      log('User with email $email not found');
      throw Exception('User with email $email not found');
    }
    return null;
  }

  Future<bool> checkIfUserIsFriend(User user, UserModel possibleFriend) async {
    final friendList = await getFriendList(user.uid, 'accepted');
    bool isFriend = false;
    for (var friend in friendList) {
      if (friend.uid == possibleFriend.uid) {
        isFriend = true;
      }
    }
    return isFriend;
  }

  Future<bool> checkIfFriendshipRequested(
      User user, UserModel possibleFriend) async {
    final friendList = await getFriendList(user.uid, 'pending');
    bool isFriendshipRequested = false;
    for (var friend in friendList) {
      if (friend.uid == possibleFriend.uid) {
        isFriendshipRequested = true;
      }
    }
    return isFriendshipRequested;
  }

  Future<List<UserModel>> getUsers() async {
    QuerySnapshot querySnapshot =
        await _database.collection(USERS_COLLECTION_PATH).get();
    List<UserModel> users = [];
    if (querySnapshot.docs.isNotEmpty) {
      // Process the retrieved users
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final UserModel user =
            UserModel.fromMap(Map<String, dynamic>.from(doc.data() as dynamic));
        users.add(user);
        // Access user data using doc.data() here
      }
    } else {
      // No users found
      log('No users found');
    }
    return users;
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _database.collection(USERS_COLLECTION_PATH).doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final UserModel user =
            UserModel.fromMap(Map<String, dynamic>.from(userData as dynamic));
        return user;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //maybe could be reafctored
  Future<Map<String, dynamic>?> _getFriendListData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _database
          .collection(FRIENDSHIPS_COLLECTION_PATH)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic>? friendList = userData['friendList'];
        return friendList;
      }
    } catch (e) {
      throw Exception(e);
    }
    return null;
  }

  Future<List<UserModel>> getFriendList(
      String userId, String friendshipStatus) async {
    List<UserModel> list = [];
    final friendListData = await _getFriendListData(userId);
    if (friendListData != null) {
      for (var entry in friendListData.entries) {
        String friendId = entry.key;
        String status = entry.value;
        if (friendshipStatus == status) {
          final friend = await getUserByUid(friendId);
          list.add(friend!);
        }
      }
    } else {
      return [];
    }
    return list;
  }

  Future<void> acceptFriendshipRequest(User user, UserModel friend) async {
    final CollectionReference friendshipsCollection =
        _database.collection(FRIENDSHIPS_COLLECTION_PATH);
    WriteBatch batch = _database.batch();

    DocumentReference userDocRef = friendshipsCollection.doc(user.uid);

    batch.update(userDocRef, {
      'friendList.${friend.uid}': 'accepted',
    });

    DocumentReference friendDocRef = friendshipsCollection.doc(friend.uid);
    batch.update(friendDocRef, {
      'friendList.${user.uid}': 'accepted',
    });

    try {
      await batch.commit();
      _addFriend(user.uid, friend.uid);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> declineFriendshipRequest(User user, UserModel friend) async {
    final CollectionReference friendshipsCollection =
        _database.collection(FRIENDSHIPS_COLLECTION_PATH);
    WriteBatch batch = _database.batch();

    DocumentReference userDocRef = friendshipsCollection.doc(user.uid);

    batch.update(userDocRef, {
      'friendList.${friend.uid}': FieldValue.delete(),
    });

    DocumentReference friendDocRef = friendshipsCollection.doc(friend.uid);
    batch.update(friendDocRef, {
      'friendList.${user.uid}': FieldValue.delete(),
    });

    try {
      await batch.commit();
      _removeFriend(user.uid, friend.uid);
    } catch (e) {
      throw Exception(e);
    }
  }

  void _addFriend(String currentUserUid, String newFriendUid) async {
    final currentUserDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);
    final newFriendDoc =
        FirebaseFirestore.instance.collection('users').doc(newFriendUid);

    final currentUserData = await currentUserDoc.get();
    final newFriendData = await newFriendDoc.get();

    Map<String, dynamic> currentUserFriends =
        Map<String, dynamic>.from(currentUserData.data()!['friends'] ?? {});
    currentUserFriends[newFriendUid] = true;

    Map<String, dynamic> newFriendFriends =
        Map<String, dynamic>.from(newFriendData.data()!['friends'] ?? {});
    newFriendFriends[currentUserUid] = true;

    await newFriendDoc.update({'friends': newFriendFriends});
    await currentUserDoc.update({'friends': currentUserFriends});
  }

  void _removeFriend(String currentUserUid, String friendUid) async {
    final currentUserDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);
    final friendDoc =
        FirebaseFirestore.instance.collection('users').doc(friendUid);

    try {
      final currentUserData = await currentUserDoc.get();
      final friendData = await friendDoc.get();

      Map<String, dynamic> currentUserFriends =
          Map<String, dynamic>.from(currentUserData.data()!['friends'] ?? {});
      currentUserFriends.remove(friendUid);

      Map<String, dynamic> friendFriends =
          Map<String, dynamic>.from(friendData.data()!['friends'] ?? {});
      friendFriends.remove(currentUserUid);

      await friendDoc.update({'friends': friendFriends});
      await currentUserDoc.update({'friends': currentUserFriends});
    } catch (e) {
      throw Exception('Error removing friend: $e');
    }
  }

  Future<void> updateLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    final DocumentReference userDocRef =
        _database.collection('users').doc(userId);

    await userDocRef.update({
      'location': GeoPoint(
        latitude,
        longitude,
      ),
    });
  }
}
