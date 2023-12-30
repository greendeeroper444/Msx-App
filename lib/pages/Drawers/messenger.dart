import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msx_app/database/messengerstore.dart';
import 'package:msx_app/pages/Drawers/chat.dart';


class MessengerPage extends StatefulWidget {
  MessengerPage({super.key});

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger'),
        // actions: [
        //   IconButton(onPressed: signOut,
        //       icon: const Icon(Icons.logout)
        //   )
        // ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList(){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return const Text('error');
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text('loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if(_auth.currentUser!.email != data['email']){
      return FutureBuilder<int>(
        future: MessengerStore().getUnreadMessageCount(data['uid']),
        builder: (context, snapshot){
          if(snapshot.hasError) {
            return const Text('error');
          }

          int unreadCount = snapshot.data ?? 0;

          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['username']),
                if (unreadCount > 0) _buildUnreadCountBadge(unreadCount),
              ],
            ),
            onTap: () async{
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: data['email'],
                    receiverUserId: data['uid'],
                  ),
                ),
              );

              // After returning from ChatPage, reset the unread count
              if (unreadCount > 0) {
                setState(() {
                  unreadCount = 0;
                });
              }
            },
          );
        },
      );
    } else {
      return Container();
    }
  }



  Widget _buildUnreadCountBadge(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red, // Customize the color as needed
      ),
      child: Text(
        '$unreadCount',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}

