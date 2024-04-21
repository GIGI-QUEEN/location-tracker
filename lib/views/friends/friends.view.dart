import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/constants/routes_names.dart';
import 'package:tutorial_firebase/models/user.model.dart';
import 'package:tutorial_firebase/providers/friendships_provider.dart';
import 'package:tutorial_firebase/services/database.service.dart';
import 'package:badges/badges.dart' as badges;

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    final friendshipsModel = Provider.of<FriendshipsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          FutureBuilder(
              future: firebaseUser != null
                  ? friendshipsModel.fetchFriendshipRequests(
                      firebaseUser, 'requested')
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error'),
                  );
                } else if (snapshot.hasData) {
                  return badges.Badge(
                    showBadge: friendshipsModel.friendshipRequestsCount > 0,
                    onTap: () {
                      Navigator.pushNamed(context, friendshipRequests);
                    },
                    badgeContent: Text(
                        friendshipsModel.friendshipRequestsCount.toString()),
                    child: const Icon(Icons.emoji_people),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, findFriends);
              },
              icon: const Icon(Icons.person_add)),
        ],
      ),
      body: FutureBuilder(
        /*  future: firebaseUser != null
            ? _databaseService.getFriendList(firebaseUser.uid, 'accepted')
            : null, */
        future: firebaseUser != null
            ? friendshipsModel.fetchFriendList(firebaseUser)
            : null, //doesn't work for some reason
        builder: (context, snapshot) {
          // log('snapshot: $snapshot');
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data is List<UserModel>) {
              final List<UserModel> friendList =
                  snapshot.data as List<UserModel>;
              return ListView.builder(
                itemCount: friendList.length,
                itemBuilder: (context, index) {
                  //    log('list: $friendList');
                  return ListTile(
                    title: Text(friendList[index].email),
                    trailing: IconButton(
                      onPressed: () async {
                        friendshipsModel.declineRequest(
                          firebaseUser!,
                          friendList[index],
                        );
                      },
                      icon: const Icon(Icons.close),
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container();
        },
      ),
    );
  }
}
