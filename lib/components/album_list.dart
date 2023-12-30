import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msx_app/components/album_card.dart';
import '../database/albumstore.dart';

class AlbumList extends StatelessWidget {
  AlbumList({super.key});

  final AlbumDatabase _albumDatabase = AlbumDatabase();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _albumDatabase.getAlbumsStream(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if(snapshot.hasError){
          print('Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        List<QueryDocumentSnapshot> albums = snapshot.data!.docs;

        return ListView.builder(
          itemCount: albums.length,
          itemBuilder: (context, index) {
            return AlbumCard(
              title: albums[index]['AlbumName'],
              documentId: albums[index].id,
            );
          },
        );
      },
    );
  }
}

