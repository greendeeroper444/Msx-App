import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msx_app/pages/Bottom_Navigation/home.dart';

import '../pages/signin.dart';
import '../pages/signin_signup.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (FirebaseAuth.instance.currentUser != null) {
          Fluttertoast.showToast(
            msg: "You need to sign out first",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            }
            else {
              return const SigninSignUpPage();
            }
          },
        ),
      ),
    );
  }
}

