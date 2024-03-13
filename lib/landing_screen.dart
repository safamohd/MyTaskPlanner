import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/screens/home.dart';
import 'package:my_task_planner/screens/login_screen.dart';
import 'package:my_task_planner/screens/tutorial_sliders.dart';
import 'package:my_task_planner/services/auth_service.dart';
import 'package:my_task_planner/utils/shared_pref.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _auth = context.read<AuthService>();
    final isLoggedIn = context.select<AuthService, bool>((service) => service.isLoggedIn);
    final myUser = context.select<AuthService, dynamic>((service) => service.myUser);
    final _firstOpen = SharedPrefUtil.isFirstOpen ?? true;
    print("LandingScreen: build with isLoggedIn: $isLoggedIn, myUser: ${myUser?.toJson()}, _firstOpen: $_firstOpen");
    return StreamBuilder(
      stream: _auth.authStateChanges,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return LoadingScreen();
        }
        if (snapshot.hasData) {
          final User user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          if (_firstOpen) return IntroScreen();
          // user might be not null depending on the local user data
          // in this case don't wait until the whole proccess to be done
          // the proccess will be finished anyway in the background
          // just go to the home screen with the user data
          // otherwise wait until either the proccess finished or the user is ready
          if (myUser != null)
            return HomeScreen(
              myUser: _auth.myUser,
            );
          if (!isLoggedIn) return LoadingScreen();
        }
        return LoginScreen();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            IMG_LOGO,
            width: size.width,
          ),
          SizedBox(
            height: marginLarge,
          ),
          Center(
            child: CircularProgressIndicator(
              color: colorPrimaryDark,
            ),
          )
        ],
      ),
    );
  }
}
