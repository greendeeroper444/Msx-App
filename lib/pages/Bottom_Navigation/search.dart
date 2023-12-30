import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msx_app/pages/play_song.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/app_bar.dart';
import '../../components/bottom_navigation.dart';
import '../../components/drawers.dart';
import '../../database/albumstore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  String searchText = "";
  String? foundSong;
  List<String> searchHistory = [];
  List<String> recommendedSongs = [];
  late SharedPreferences prefs;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState(){
    super.initState();
    initSharedPreferences();
    loadSearchHistory();
  }

  Future<void> initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
  }

  String getSearchHistoryKey(){
    String userUid = user?.uid ?? "guest";
    return 'searchHistory_$userUid';
  }

  Future<void> loadSearchHistory() async{
    await initSharedPreferences();
    setState(() {
      searchHistory = prefs.getStringList(getSearchHistoryKey()) ?? [];
    });
  }
  void saveSearchHistory(){
    prefs.setStringList(getSearchHistoryKey(), searchHistory);
  }

  void addToSearchHistory(String term){
    setState(() {
      if(!searchHistory.contains(term)){
        searchHistory.add(term);
        saveSearchHistory();
      }
    });
  }

  void removeFromSearchHistory(String term){
    setState(() {
      searchHistory.remove(term);
      saveSearchHistory();
    });
  }

  void clearSearchHistory(){
    setState(() {
      searchHistory.clear();
      saveSearchHistory();
    });
  }

  void binarySearch(String target) async{
    try {
      final List<DocumentSnapshot> songs = await AlbumDatabase().getSongByTitle(target);

      addToSearchHistory(target);

      if(songs.isNotEmpty){
        setState(() {
          foundSong = songs[0]['Title'];
        });
      }else{
        setState(() {
          foundSong = null;
        });
      }
    } catch (e) {
      print('Error during song search: $e');
      setState(() {
        foundSong = null;
      });
    }
  }

  void getRecommendations(String query) async{
    try {
      List<String> recommendations = await AlbumDatabase().getRecommendations(query);
      setState(() {
        recommendedSongs = recommendations;
      });
    } catch (e) {
      print("Error getting recommendations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(0),
                child: Text(
                  'Search',
                  style: TextStyle(fontSize: 30,
                      fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: searchController,
                onChanged: (value){
                  setState((){
                    searchText = value;
                  });
                  getRecommendations(value);
                },
                onSubmitted: (value){
                  binarySearch(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search for a song',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      binarySearch(searchText);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if(foundSong != null)
                ListTile(
                  title: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white),

                        const SizedBox(width: 8.0),

                        Text(
                          '$foundSong',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  onTap: () async {
                    addToSearchHistory(searchText);
                    String foundSongTitle = foundSong!;
                    List<DocumentSnapshot> songs = await AlbumDatabase().getSongByTitle(foundSongTitle);

                    if(songs.isNotEmpty){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaySongPage(
                            songTitle: songs[0]['Title'],
                            artist: songs[0]['Artist'],
                            songUid: songs[0].id,
                            fileUrl: songs[0]['FileUrl'],
                          ),
                        ),
                      );
                    }
                  },
                ),

              //recommended songs
              if(recommendedSongs.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: recommendedSongs
                            .map(
                              (song) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: (){
                                searchController.text = song;
                                binarySearch(song);
                              },
                              child: Text(
                                song,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),
          
              const SizedBox(height: 20),
          
              if(foundSong == null && searchText.isNotEmpty)
                const Center(
                  child: Text(
                    'Sorry, the song was not found.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 40),
          
              //searchhistory
              if (searchHistory.isNotEmpty)
                Container(
                  height: 250,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Search History',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: searchHistory
                              .map(
                                (term) => ListTile(
                              title: Text(
                                term,
                              ),
                              onTap: () {
                                searchController.text = term;
                                binarySearch(term);
                              },
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  removeFromSearchHistory(term);
                                },
                              ),
                            ),
                          )
                              .toList(),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            clearSearchHistory();
                          },
                          child: const Text('Clear History'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/library');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 3:
            // Navigator.pushReplacementNamed(context, '/search');
              break;
          }
        },
      ),
    );
  }
}

