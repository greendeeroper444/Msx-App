import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msx_app/database/messengerstore.dart';

import '../../components/textfields.dart';


class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  const ChatPage({
    super.key,
    required this.receiverUserId,
    required this.receiverUserEmail
  });


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final MessengerStore _messengerStore =MessengerStore();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async{
    //only send messsaeg if there is something to send
    if(_messageController.text.isNotEmpty){
      await _messengerStore.sendMessage(
          widget.receiverUserId, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _messengerStore.getUnreadMessageCount(widget.receiverUserId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: FutureBuilder(
          future: _messengerStore.getUsername(widget.receiverUserId),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Text("Loading...");
            }else if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }else{
              String senderUsername = snapshot.data.toString();
              return Text(senderUsername);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: _buildMessageList()
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _messengerStore.getMessages(
        widget.receiverUserId,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot){
        if(snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading...");
        }

        _messengerStore.markMessagesAsRead(_firebaseAuth.currentUser!.uid, widget.receiverUserId);

        return ListView.builder(
          reverse: false,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }


  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;
    var alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // if (!isCurrentUser) _buildAvatar(data['senderAvatar']),
          _buildMessageBubble(data['message'], isCurrentUser),
          _buildTimestamp(data['timestamp']),
        ],
      ),
    );
  }

  // Widget _buildAvatar(String? senderAvatar) {
  //   return CircleAvatar(
  //     backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar) : null,
  //     radius: 16.0,
  //   );
  // }


  Widget _buildMessageBubble(String message, bool isCurrentUser){
    var bgColor = isCurrentUser ? const Color.fromARGB(255, 148, 87, 235) : Colors.grey.shade200;
    var textColor = isCurrentUser ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Text(
        message,
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildTimestamp(Timestamp timestamp){
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('jm').format(dateTime);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        formattedTime,
        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
      ),
    );
  }

  Widget _buildMessageInput(){
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTypingField(
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, size: 24.0),
          ),
        ],
      ),
    );
  }


}
