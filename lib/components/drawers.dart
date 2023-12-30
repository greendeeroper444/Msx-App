import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../pages/signin_signup.dart';
import '../services/authservice.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final AuthService authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    String email = FirebaseAuth.instance.currentUser?.email ?? "";
    String mobile = "";

    String identifier = uid.isNotEmpty ? uid : (email.isNotEmpty ? email : mobile);

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

  String _truncateUsername(String username){
    const int maxUsernameLength = 8;

    if(username.length <= maxUsernameLength){
      return username;
    } else{
      return '${username.substring(0, maxUsernameLength)}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot){
         if(snapshot.hasError){
            return Text("Error: ${snapshot.error}");
          }
          else if(snapshot.hasData){
            Map<String, dynamic>? user = snapshot.data!.data();
            String profileImageUrl = user?['profileImageUrl'] ?? '';

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 100,
                      ),
                      child: GestureDetector(
                        onTap: (){
                          Scaffold.of(context).openDrawer();
                        },
                        child: profileImageUrl.isNotEmpty
                            ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              profileImageUrl),
                        )
                            : const ClipOval(
                          child: Icon(Icons.account_circle, size: 100),
                        ),
                      ),
                    ),
                    Text(
                      "@${_truncateUsername(user!['username'])}",
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text("Edit Profile"),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.album),
                          title: const Text("Create Album"),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(context, '/create_album');
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.public),
                          title: const Text("Public Albums"),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(context, '/public_albums');
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.messenger),
                          title: const Text("Messenger"),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(context, '/messenger');
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text("Settings"),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(context, '/setting');
                          },
                        ),
                      ),
                    ),

                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 25),
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("S I G N O U T"),
                    onTap: () {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "You are now signed out of MSX",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black.withOpacity(0.7),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                      signOutUser();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const SigninSignUpPage()),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            // Return an empty container if no data is available
            return Container();
          }
        },
      ),
    );
  }
}
