import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msx_app/pages/play_song.dart';
import '../../components/app_bar.dart';
import '../../components/bottom_navigation.dart';
import '../../components/drawers.dart';
import '../../database/albumstore.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late List<DocumentSnapshot> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteSongs();
  }

  void _loadFavoriteSongs() async {
    List<DocumentSnapshot> songs = await AlbumDatabase().getFavoriteSongs();
    setState(() {
      favoriteSongs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const MyDrawer(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Favorite',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: favoriteSongs.length,
                itemBuilder: (context, index){
                  DocumentSnapshot song = favoriteSongs[index];
                  return ListTile(
                    title: Text(song['Title'] ?? ''),
                    subtitle: Text(song['Artist'] ?? ''),
                    trailing: const Icon(Icons.favorite, color: Colors.red),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaySongPage(
                            songTitle: song['Title'] ?? '',
                            artist: song['Artist'] ?? '',
                            songUid: song.id,
                            fileUrl: song['FileUrl'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/library');
              break;
            case 2:
            // Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/search');
              break;
          }
        },
      ),
    );
  }
}

