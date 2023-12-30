import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateUserDataInFirestore({
    required String uid,
    required String email,
    required String username,
    String? profileImageUrl,
  }) async {
    Map<String, dynamic> userData = {
      'uid': uid,
      'email': email,
      'username': username,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };

    await FirebaseFirestore.instance.collection("Users").doc(uid).set(userData);
  }



}

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    await GoogleSignIn().signOut();

    //trigger google signin
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    if(googleSignInAccount == null){
      showToast("Sign in canceled by user");
      return;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if(user != null){
      final profileImageUrl = user.photoURL;

      await AuthService().updateUserDataInFirestore(
        uid: user.uid,
        email: user.email!,
        username: user.displayName ?? "",
        profileImageUrl: profileImageUrl,
      );

      Navigator.pushReplacementNamed(context, '/home');

      Fluttertoast.showToast(
        msg: "Continue as ${user.displayName}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }else{
      showToast("Sign in failed");
    }
  } catch (e) {
    print("Error signing in with Google: $e");
    showToast("Sign in failed");
  }
}

Future<void> signInWithFacebook(BuildContext context) async {
  try {
    await FacebookAuth.instance.logOut();

    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'email'],
      loginBehavior: LoginBehavior.dialogOnly,
    );

    if(result.status == LoginStatus.success){
      final AccessToken accessToken = result.accessToken!;
      final AuthCredential credential =
      FacebookAuthProvider.credential(accessToken.token);

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = userCredential.user!;

      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,picture.type(large)",
      );

      final facebookName = userData['name'];

      //Get the profile picture URL from public_profile data
      final profileImageUrl = userData['picture']['data']['url'];

      //Update user details in Firestore
      await AuthService().updateUserDataInFirestore(
        uid: user.uid,
        email: user.email!,
        username: facebookName,
        profileImageUrl: profileImageUrl,
      );

      Navigator.pushReplacementNamed(context, '/home');

      Fluttertoast.showToast(
        msg: "Continue as $facebookName",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else{
      print(
          "Facebook Login Failed - Status: ${result.status}, Message: ${result.message}");
      showToast("Sign in canceled by user");
    }
  } catch (e) {
    print("Error signing in with Facebook: $e");
    showToast("Sign in failed");
  }
}


void showToast(String message){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey.shade600,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
