import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/components/centered_circular_progress_indicator.dart';
import 'package:tutorial_firebase/models/user.model.dart';
import 'package:tutorial_firebase/providers/search_users_provider.dart';

class FindFriendsView extends StatelessWidget {
  FindFriendsView({super.key});
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchModel = Provider.of<SearchUsersProvider>(context);
    final firebaseUser = context.watch<User?>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for users'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              searchModel.clear();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'enter user email',
                suffixIcon: IconButton(
                    onPressed: () {
                      if (firebaseUser != null) {
                        searchModel.peformSearch(
                            firebaseUser, _textController.text.trim());
                      }
                    },
                    icon: const Icon(Icons.search)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                searchModel.loading
                    ? const CenteredCircularProgressIndicator()
                    : Expanded(
                        child: FoundUser(
                          user: searchModel.foundUser,
                          errorMsg: searchModel.errorMsg,
                          isFriend: searchModel.isFriend,
                          isFriendshipRequested:
                              searchModel.isFriendshipRequested,
                        ),
                      )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class FoundUser extends StatelessWidget {
  const FoundUser(
      {super.key,
      required this.user,
      this.errorMsg,
      required this.isFriend,
      required this.isFriendshipRequested});
  final UserModel? user;
  final String? errorMsg;
  final bool isFriend;
  final bool isFriendshipRequested;

  @override
  Widget build(BuildContext context) {
    final searchModel = Provider.of<SearchUsersProvider>(context);
    final firebaseUser = context.watch<User?>();
    if (errorMsg != null) {
      return Text(errorMsg!);
    } else if (user == null) {
      return const Text('');
    } else {
      return ListTile(
        title: Text(user!.email),
        trailing: IconButton(
            onPressed: isFriend || isFriendshipRequested
                ? null
                : () async {
                    if (firebaseUser != null) {
                      await searchModel.sendFriendShipRequest(
                          firebaseUser, user!);
                    }
                  },
            icon: isFriend || isFriendshipRequested
                ? const Icon(Icons.check)
                : const Icon(Icons.add)),
      );
    }
  }
}
