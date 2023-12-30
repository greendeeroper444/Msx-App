import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authservice.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});

  final AuthService authService = AuthService();
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final String email = FirebaseAuth.instance.currentUser?.email ?? "";
  final String mobile = "";

  String getIdentifier() {
    return uid.isNotEmpty ? uid : (email.isNotEmpty ? email : mobile);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async{
    String identifier = getIdentifier();
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance.collection("Users")
        .doc(identifier)
        .get();

    if(!snapshot.exists && email.isNotEmpty){
      snapshot = await FirebaseFirestore
          .instance.collection("Users")
          .doc(email)
          .get();
    }

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (BuildContext context) {
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getUserDetails(),
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    Map<String, dynamic>? user = snapshot.data!.data();
                    String profileImageUrl = user?['profileImageUrl'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: profileImageUrl.isNotEmpty
                          ? CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                            profileImageUrl),
                      )
                          : const ClipOval(
                        child: Icon(Icons.account_circle, size: 50),
                      ),
                    );

                  } else {
                    return const SizedBox();
                  }
                },
              );
            },
          ),
          Image.asset(
            "assets/msx_logo.png",
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ],
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Divider(
          color: Colors.grey.withOpacity(0.10),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
