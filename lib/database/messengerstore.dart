import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/messenges.dart';


class MessengerStore extends ChangeNotifier{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;


  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if(currentUser == null) {
        print('Error: Current user is null');
        return;
      }

      final String currentUserId = currentUser.uid;

      String currentUserUsername = await getUsername(currentUserId);

      final Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(
        senderId: currentUserId,
        senderUsername: currentUserUsername,
        receiverId: receiverId,
        timestamp: timestamp,
        message: message,
        isRead: false,
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      await _fireStore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      print('Error sending message: $e');
    }
  }


  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false).snapshots();
  }



  Future<int> getUnreadMessageCount(String otherUserId) async {
    final User? currentUser = _firebaseAuth.currentUser;

    if(currentUser == null){
      return 0;
    }

    try {
      List<String> ids = [currentUser.uid, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      //Get unread messages
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _fireStore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error getting unread message count: $e');
      return 0;
    }
  }

  Future<void> markMessagesAsRead(String userId, String otherUserId) async {
    try {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _fireStore
          .collection('ChatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for(QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs){
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<String> getUsername(String userId) async{
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await _fireStore
          .collection("Users")
          .doc(userId)
          .get();
      return userSnapshot['username'];
    } catch (e) {
      print('Error getting username: $e');
      return '';
    }
  }

}