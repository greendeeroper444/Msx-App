import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msx_app/pages/play_song.dart';
import '../database/albumstore.dart';

class RecentMusicFeature extends StatelessWidget {
  const RecentMusicFeature({super.key});

  String _formatTimestamp(DateTime dateTime){
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Music',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: AlbumDatabase().getRecentlyPlayedSongs(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              List<QueryDocumentSnapshot<Map<String, dynamic>>> songs =
                  snapshot.data!.docs;
              return Column(
                children: songs.map((song){
                  return _buildMusicItem(context, song);
                }).toList(),
              );
            }else{
              return const CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMusicItem(
      BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> song){
    String musicTitle = song['Title'] as String? ?? 'Unknown Title';
    String fileUrl = song['FileUrl'] as String? ?? 'default_file_url';

    Timestamp timestamp = song['Timestamp'] as Timestamp? ?? Timestamp.now();
    DateTime dateTime = timestamp.toDate();
    String formattedTime = _formatTimestamp(dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 150,
                height: 50,
                child: Center(
                  child: Text(
                    musicTitle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaySongPage(
                        songTitle: musicTitle,
                        artist: 'Artist',
                        songUid: 'SongUid',
                        fileUrl: fileUrl,
                      ),
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    String artist = 'Artist';
                    String songUid = 'SongUid';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaySongPage(
                          songTitle: musicTitle,
                          artist: artist,
                          fileUrl: fileUrl,
                          songUid: songUid,
                        ),
                      ),
                    );
                  },
                  child: const Text('Play'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$formattedTime',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey
            ),
          ),
        ],
      ),
    );
  }
}
