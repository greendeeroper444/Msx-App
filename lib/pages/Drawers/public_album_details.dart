import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msx_app/components/song_card.dart';
import 'package:msx_app/pages/play_song.dart';
import '../../database/albumstore.dart';

class PublicAlbumDetailPage extends StatefulWidget {
  final String albumId;

  const PublicAlbumDetailPage({
    super.key,
    required this.albumId
  });

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<PublicAlbumDetailPage> {
  final AlbumDatabase _albumDatabase = AlbumDatabase();
  late Future<String?> _albumNameFuture;
  bool conditionMet = false;

  @override
  void initState(){
    super.initState();
    _albumNameFuture = _fetchAlbumName();
  }

  Future<String?> _fetchAlbumName() async {
    try {
      final String? name = await _albumDatabase.getAlbumName(
          widget.albumId);
      if(name != null){
        return name;
      }else{
        print("Album name not available for ID: ${widget.albumId}");
        return null;
      }
    } catch (e) {
      print("Error fetching album name: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: _albumNameFuture,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Text('Loading...');
            }else if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }else {
              return Text('${snapshot.data ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: _albumDatabase.getSongsForPublicAlbum(widget.albumId),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }

          if(snapshot.hasError){
            return Text('Error: ${snapshot.error}');
          }

          List<DocumentSnapshot> songs = snapshot.data ?? [];

          if(songs.isEmpty){
            return const Center(
              child: Text('No songs in this album'),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index){
              DocumentSnapshot songSnapshot = songs[index];

              if (songSnapshot.exists) {
                String title = songSnapshot['Title'] ?? '';
                String artist = songSnapshot['Artist'] ?? '';
                String fileUrl = songSnapshot['FileUrl'] ?? '';

                return SongCard(
                  title: title,
                  artist: artist,
                  fileUrl: fileUrl,
                  onTap: (){
                    _navigateToPlayPage(context, songSnapshot);
                  },
                  onEdit: () {

                  },
                  onDelete: (){
                    // _deleteSongs(context, songSnapshot.id);
                  },
                );
              } else{
                return Container();
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToPlayPage(BuildContext context, DocumentSnapshot song) {
    String title = song['Title'] ?? '';
    String artist = song['Artist'] ?? '';
    String fileUrl = song['FileUrl'] ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaySongPage(
          songTitle: title,
          songUid: song.id,
          fileUrl: fileUrl,
          artist: artist,
        ),
      ),
    );
  }
}
