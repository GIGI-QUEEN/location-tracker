import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/constants/routes_names.dart';
import 'package:tutorial_firebase/providers/authentication_provider.dart';
import 'package:tutorial_firebase/providers/friendships_provider.dart';
import 'package:tutorial_firebase/providers/location_provider.dart';
import 'package:tutorial_firebase/providers/search_users_provider.dart';
import 'package:tutorial_firebase/theme.dart';
import 'package:tutorial_firebase/views/auth/login.view.dart';
import 'package:tutorial_firebase/views/auth/signup.view.dart';
import 'package:tutorial_firebase/views/auth/authenticate.view.dart';
import 'package:tutorial_firebase/views/friends/add_friend.view.dart';
import 'package:tutorial_firebase/views/friends/friendship_requests.view.dart';
import 'package:tutorial_firebase/views/main.view.dart';
import 'package:tutorial_firebase/services/user_location_initializer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    initUserLocation();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationProvider>().authState,
          initialData: null,
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(create: (_) => SearchUsersProvider()),
        ChangeNotifierProvider(create: (_) => FriendshipsProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: darkTheme,
        debugShowCheckedModeBanner: false,
        routes: {
          signIn: (context) => const LoginView(),
          signUp: (context) => const SignupView(),
          authenticate: (context) => const Authenticate(),
          mainPage: (context) => const MainView(),
          findFriends: (context) => FindFriendsView(),
          friendshipRequests: (context) => const FriendShipsRequestsView(),
        },
        home: Builder(
          builder: (context) {
            final locationProvider =
                Provider.of<LocationProvider>(context, listen: false);
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser != null) {
              locationProvider.startFriendsListening(currentUser.uid);
              return const MainView();
            } else {
              return const Authenticate();
            }
          },
        ),
      ),
    );
  }
}
