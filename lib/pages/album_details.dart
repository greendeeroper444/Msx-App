import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msx_app/components/song_card.dart';
import 'package:msx_app/pages/play_song.dart';
import 'package:msx_app/pages/upload_music.dart';
import '../database/albumstore.dart';

class AlbumDetailPage extends StatefulWidget {
  final String albumId;

  const AlbumDetailPage({
    super.key,
    required this.albumId
  });

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  final AlbumDatabase _albumDatabase = AlbumDatabase();
  late Future<String?> _albumNameFuture;
  final CollectionReference<Map<String, dynamic>> songs =
  FirebaseFirestore.instance.collection('Songs');

  @override
  void initState() {
    super.initState();
    _albumNameFuture = _fetchAlbumName();
  }

  Future<String?> _fetchAlbumName() async {
    try {
      final String? name = await _albumDatabase.getAlbumName(
          widget.albumId);
      if (name != null) {
        return name;
      } else {
        print("Album name not available for ID: ${widget.albumId}");
        return null;
      }
    } catch (e) {
      print("Error fetching album name: $e");
      return null;
    }
  }

  Future<void> _deleteSongs(BuildContext context, String songId) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Song'),
            content: const Text('Are you sure you want to delete the song?'),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context, true);
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await _albumDatabase.deleteSongs(songId);

        Fluttertoast.showToast(
          msg: 'The song deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting song: $e');
    }
  }


  //edit
  Future<void> _editSong(BuildContext context, String songId, String currentTitle, String currentArtist) async{
    TextEditingController _titleController = TextEditingController(text: currentTitle);
    TextEditingController _artistController = TextEditingController(text: currentArtist);

    await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Edit Song'),
          content: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'New Song Title'),
              ),
              TextField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'New Artist'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{

                String newTitle = _titleController.text.trim();
                String newArtist = _artistController.text.trim();
                if(newTitle.isNotEmpty && newArtist.isNotEmpty) {
                  await _albumDatabase.editSong(songId, newTitle, newArtist);

                  setState(() {});
                }

                Fluttertoast.showToast(
                  msg: 'The song updated successfully',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: _albumNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('${snapshot.data ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: _albumDatabase.getSongsForAlbum(widget.albumId),
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
            itemBuilder: (context, index) {
              DocumentSnapshot songSnapshot = songs[index];

              if (songSnapshot.exists) {
                String title = songSnapshot['Title'] ?? '';
                String artist = songSnapshot['Artist'] ?? '';
                String fileUrl = songSnapshot['FileUrl'] ?? '';

                return SongCard(
                  title: title,
                  artist: artist,
                  fileUrl: fileUrl,
                  onTap: () {
                    _navigateToPlayPage(context, songSnapshot);
                  },
                  onEdit: () {
                    _editSong(context, songs[index].id, title, artist);
                  },
                  onDelete: (){
                    _deleteSongs(context, songSnapshot.id);
                  },
                );
              } else{
                return Container();
              }
            },
          );

        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 50.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UploadMusicPage(albumId: widget.albumId,),
                  ),
                ).then((value) async {
                  setState(() {});
                });
              },
              child: Icon(Icons.add),
              heroTag: null,
            ),
          ),
        ],
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
