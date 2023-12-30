import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msx_app/database/albumstore.dart';
import 'package:msx_app/pages/Drawers/public_album_details.dart';

class PublicPage extends StatelessWidget {
  const PublicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Public Albums',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
      ),
      body: StreamBuilder(
        stream: AlbumDatabase().getPublicAlbumsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else if (snapshot.hasError){
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }else if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return const Center(
              child: Text('No public albums found.'),
            );
          }else{
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var albumData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                var albumName = albumData['AlbumName'];
                var username = albumData['Username'];
                var albumId = snapshot.data!.docs[index].id;

                return GestureDetector(
                  onTap: () {
                    _navigateToAlbumDetails(context, albumId);
                  },
                  child: ListTile(
                    title: Text(
                      albumName,
                      style: const TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(
                      'Uploaded by: $username',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToAlbumDetails(BuildContext context, String albumId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicAlbumDetailPage(albumId: albumId),
      ),
    );
  }
}
