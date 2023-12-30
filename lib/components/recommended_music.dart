import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/albumstore.dart';
import '../pages/play_song.dart';

class RecommendedMusicFeature extends StatelessWidget {
  const RecommendedMusicFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: StreamBuilder<QuerySnapshot>(
            stream: AlbumDatabase().getAllSongsPublicStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> songs = snapshot.data!.docs;
                return Row(
                  children: songs.map((song) {
                    return _buildMusicItem(
                      context,
                      song['Title'],
                      song['Artist'],
                      song['FileUrl'],
                      song.id,
                    );
                  }).toList(),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMusicItem(BuildContext context, String title, String artist, String fileUrl, String songUid){
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 150,
            height: 50,
            child: Center(
              child: Text(
                title,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaySongPage(
                    songTitle: title,
                    artist: artist,
                    fileUrl: fileUrl,
                    songUid: songUid,
                  ),
                ),
              );
            },
            child: Text('Play'),
          ),
        ],
      ),
    );
  }
}
