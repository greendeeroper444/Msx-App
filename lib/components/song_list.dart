import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msx_app/components/song_card.dart';
import '../database/albumstore.dart';
import '../pages/play_song.dart';

class SongList extends StatefulWidget {
  const SongList({super.key});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  final AlbumDatabase _albumDatabase = AlbumDatabase();

  Future<void> _deleteSongs(BuildContext context, String songId, String title) async{
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context){
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
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if(confirmDelete == true){
        await _albumDatabase.deleteSongs(songId);

        Fluttertoast.showToast(
          msg: 'The song deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      Navigator.popUntil(context, ModalRoute.withName('/library'));
    } catch (e) {
      print('Error deleting song: $e');
    }
  }

  //edit
  Future<void> _editSong(
      BuildContext context, String songId, String currentTitle, String currentArtist) async{
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
                if(newTitle.isNotEmpty && newArtist.isNotEmpty){
                  await _albumDatabase.editSong(songId, newTitle, newArtist);
                  setState(() {});
                }

                Fluttertoast.showToast(
                  msg: 'The song updated successfully',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );

                Navigator.popUntil(context, ModalRoute.withName('/library'));
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
    return StreamBuilder(
      stream: _albumDatabase.getAllSongsStream(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return CircularProgressIndicator();
        }

        if(snapshot.hasError){
          return Text('Error: ${snapshot.error}');
        }

        List<DocumentSnapshot> songs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index){
            DocumentSnapshot songSnapshot = songs[index];

            return SongCard(
              title: songSnapshot['Title'],
              artist: songSnapshot['Artist'],
              fileUrl: songSnapshot['FileUrl'],
              onTap: (){
                _navigateToPlayPage(context, songSnapshot);
              },
              onEdit: (){
                _editSong(context, songSnapshot.id, songSnapshot['Title'], songSnapshot['Artist']);
              },
              onDelete: (){
                _deleteSongs(context, songSnapshot.id, songSnapshot['Title']);
              },
            );
          },
        );
      },
    );
  }

  void _navigateToPlayPage(BuildContext context, DocumentSnapshot song) {
    String title = song['Title'];
    String artist = song['Artist'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaySongPage(
          songTitle: title,
          songUid: song.id,
          fileUrl: song['FileUrl'],
          artist: artist,
        ),
      ),
    );
  }
}
