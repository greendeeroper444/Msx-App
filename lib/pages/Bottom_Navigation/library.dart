import 'package:flutter/material.dart';
import '../../components/album_list.dart';
import '../../components/app_bar.dart';
import '../../components/bottom_navigation.dart';
import '../../components/drawers.dart';
import '../../components/song_list.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const MyDrawer(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Library',
              style: TextStyle(fontSize: 30,
                  fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("My All Songs",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: SongList(),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("My Albums",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: AlbumList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Navigator.pushReplacementNamed(context, '/library');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/favorites');
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



