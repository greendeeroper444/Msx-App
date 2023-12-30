import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthStore {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Widget getProfileImage({double size = 40.0, String? profileImageUrl}){
    if (profileImageUrl != null && profileImageUrl.isNotEmpty){
      return ClipOval(
        child: Image.network(
          profileImageUrl,
          height: size,
          width: size,
          fit: BoxFit.contain,
        ),
      );
    }else if(_firebaseAuth.currentUser?.photoURL != null){
      return ClipOval(
        child: Image.network(
          _firebaseAuth.currentUser!.photoURL!,
          height: size,
          width: size,
          fit: BoxFit.contain,
        ),
      );
    }else if (_firebaseAuth.currentUser?.providerData.isNotEmpty ?? false){
      var providerData = _firebaseAuth.currentUser!.providerData.first;
      if(providerData.providerId == 'facebook.com'){
        return ClipOval(
          child: Image.network(
            providerData.photoURL!,
            height: size,
            width: size,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    return ClipOval(
      child: Icon(Icons.account_circle, size: size),
    );
  }


  Future<void> editUserProfile({
    required String uid,
    String? newUsername,
    String? newProfileImageUrl,
    String? newProfileUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if(newUsername != null){
        updateData['username'] = newUsername;
      }
      if(newProfileImageUrl != null){
        updateData['profileImageUrl'] = newProfileImageUrl;
      }
      if(newProfileUrl != null){
        updateData['profileUrl'] = newProfileUrl;
      }

      if(updateData.isNotEmpty){
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .update(updateData);
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final imageRef = storage.ref().child('profile_images/$uid.jpg');
      await imageRef.putFile(imageFile);

      //get the download URL
      final imageUrl = await imageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }
}
