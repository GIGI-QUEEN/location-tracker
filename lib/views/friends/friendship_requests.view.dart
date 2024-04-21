import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/providers/friendships_provider.dart';

class FriendShipsRequestsView extends StatelessWidget {
  const FriendShipsRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    final friendshipsModel = Provider.of<FriendshipsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friendship requests'),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: friendshipsModel.fetchFriendshipRequests(
              firebaseUser!, 'requested'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              log("data: ${snapshot.data}");
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    final friend = snapshot.data![index];
                    return ListTile(
                      title: Text(friend.email),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () async {
                              friendshipsModel.acceptRequest(
                                  firebaseUser, friend);
                            },
                            child: const Text('Accept friend'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              friendshipsModel.declineRequest(
                                  firebaseUser, friend);
                            },
                            child: const Text('Decline friend'),
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
