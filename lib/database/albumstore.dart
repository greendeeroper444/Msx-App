import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AlbumDatabase {
  User? get user => FirebaseAuth.instance.currentUser;
  final CollectionReference albums = FirebaseFirestore.instance.collection('Albums');
  final CollectionReference songs = FirebaseFirestore.instance.collection('Songs');
  final CollectionReference users = FirebaseFirestore.instance.collection('Users');

  Future<DocumentReference> addAlbum(String albumName) async{

    DocumentSnapshot userSnapshot = await users.doc(user?.uid).get();
    String? username = (userSnapshot.data() as Map<String, dynamic>?)?['username'];

    final DocumentReference docRef = await albums.add({
      'AlbumName': albumName,
      'TimeStamp': FieldValue.serverTimestamp(),
      'UserEmail': user?.email,
      'Username': username,
      'UserUid': user?.uid,
    });

    await docRef.update({
      'AlbumId': docRef.id,
    });

    return docRef;
  }

  Stream<QuerySnapshot> getAlbumsStream(){
    return albums
        .where('UserUid', isEqualTo: user?.uid)
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  //count same album name
  Future<String>getAvailableAlbumName(String albumName) async{
    int suffix = 0;

    while(await doesAlbumExist('$albumName${suffix != 0 ? ' ($suffix)' : ''}')) {
      suffix++;
    }

    return '$albumName${suffix != 0 ? ' ($suffix)' : ''}';
  }

  Future<bool> doesAlbumExist(String albumName) async{
    QuerySnapshot querySnapshot = await albums
        .where('UserUid', isEqualTo: user?.uid)
        .where('AlbumName', isEqualTo: albumName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateAlbum(String oldAlbumName, String newAlbumName) async{
    try {
      final QuerySnapshot querySnapshot =
      await albums.where('AlbumName', isEqualTo: oldAlbumName).get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        await albums.doc(documents.first.id).update({
          'AlbumName': newAlbumName,
        });
      }
    } catch (e) {
      print("Error updating album: $e");
    }
  }

  Future<String?> getAlbumName(String albumId) async{
    try {
      final DocumentSnapshot albumSnapshot =
      await albums.doc(albumId).get();

      if(albumSnapshot.exists) {
        return albumSnapshot['AlbumName'] as String?;
      }else{
        print("Album not found for ID: $albumId");
        return null;
      }
    } catch (e) {
      print("Error getting album name: $e");
      return null;
    }
  }

  //delete album
  Future<void> deleteAlbumAndSongs(String albumId, String albumName) async{
    try {
      await _deleteSongsForAlbum(albumId);

      await albums.doc(albumId).delete();

      print('Album "$albumName" and associated songs deleted successfully.');
    } catch (e) {
      print('Error deleting album and songs: $e');
      rethrow;
    }
  }

  Future<void> _deleteSongsForAlbum(String albumId) async {
    try {
      QuerySnapshot querySnapshot = await songs.where('Album', isEqualTo: albums.doc(albumId)).get();
      List<QueryDocumentSnapshot> songsToDelete = querySnapshot.docs;

      //Delete each song
      for(QueryDocumentSnapshot song in songsToDelete){
        await song.reference.delete();
      }

      print('Songs associated with the album deleted successfully.');
    } catch (e) {
      print('Error deleting songs for the album: $e');
      rethrow;
    }
  }


//add song to album
  Future<void> addSongToAlbum(String albumId, String title, String artist, String fileUrl) async{
    try {
      if(albumId.isNotEmpty){
        Timestamp timestamp = Timestamp.now();

        DocumentReference songReference = await songs.add({
          'Title': title,
          'Artist': artist,
          'FileUrl': fileUrl,
          'StorageUrl': '',
          'Album': albums.doc(albumId),
          'Timestamp': timestamp,
          'isFavorite': false,
          'songId': UniqueKey().toString(),
          'UserEmail': user?.email,
          'UserUid': user?.uid,
        });

        await albums.doc(albumId).update({
          'Songs': FieldValue.arrayUnion([songReference]),
        });
      } else{
        print("Error adding song to album: Invalid albumId");
      }
    } catch (e) {
      print("Error adding song to album: $e");
    }
  }

  Future<String> getAvailableSongTitle(String albumId, String title) async{
    int suffix = 1;

    while (await doesSongExist(albumId, title, suffix)){
      suffix++;
    }

    return(suffix > 1) ? '$title ($suffix)' : title;
  }

  Future<bool> doesSongExist(String albumId, String title, int suffix) async {
    QuerySnapshot querySnapshot = await songs
        .where('Album', isEqualTo: albums.doc(albumId))
        .where('Title', isEqualTo: (suffix > 1) ? '$title ($suffix)' : title)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<DocumentSnapshot>> getSongsForAlbum(String albumId){
    return albums
        .where('AlbumId', isEqualTo: albumId)
        .where('UserUid', isEqualTo: user?.uid)
        .snapshots()
        .map((albumSnapshot){
      if(albumSnapshot.docs.isNotEmpty){
        Map<String, dynamic> albumData = albumSnapshot.docs.first.data() as Map<String, dynamic>;

        if(albumData.containsKey('Songs')){
          List<dynamic> songsRefs = albumData['Songs'] ?? [];
          return songsRefs.cast<DocumentReference>();
        }else {
          print("Error: 'Songs' field not found in the document");
          return [];
        }
      } else{
        return [];
      }
    }).asyncMap((songReferences) async {
      List<DocumentSnapshot> songsData = [];
      for (DocumentReference songRef in songReferences) {
        DocumentSnapshot songSnapshot = await songRef.get();
        songsData.add(songSnapshot);
      }
      return songsData;
    });
  }

  Stream<QuerySnapshot> getAllSongsStream(){
    return songs
        .where('UserUid', isEqualTo: user?.uid)
        .orderBy('Title')
        .snapshots();
  }

  Future<void> updateSongStorageUrl(String albumName, String title, String artist, String storageUrl) async{
    try {
      final QuerySnapshot querySnapshot =
      await albums.where('AlbumName', isEqualTo: albumName).get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;

      if(documents.isNotEmpty){
        final List<dynamic> songs = documents.first['Songs'] ?? [];
        int songIndex = _findSongIndexByTitleAndArtist(songs, title, artist);

        if(songIndex != -1){
          songs[songIndex]['StorageUrl'] = storageUrl;
          await albums.doc(documents.first.id).update({'Songs': songs});
        }
      }
    } catch (e) {
      print("Error updating song storage URL: $e");
    }
  }

  int _findSongIndexByTitleAndArtist(List<dynamic> songs, String title, String artist){
    for(int i = 0; i < songs.length; i++){
      if(songs[i]['title'] == title && songs[i]['artist'] == artist){
        return i;
      }
    }
    return -1;
  }

  Stream<List<DocumentSnapshot>> getSongsStreamForAlbum(String albumName){
    return albums
        .where('AlbumName', isEqualTo: albumName)
        .snapshots()
        .map((albumSnapshot) {
      if(albumSnapshot.docs.isNotEmpty) {
        List<dynamic> songs = albumSnapshot.docs.first['Songs'] ?? [];
        return songs.cast<DocumentReference>();
      }else{
        return [];
      }
    }).asyncMap((songReferences) async{
      List<DocumentSnapshot> songsData = [];
      for (DocumentReference songRef in songReferences){
        DocumentSnapshot songSnapshot = await songRef.get();
        songsData.add(songSnapshot);
      }
      return songsData;
    });
  }

  //delete songs
  Future<void> deleteSongs(String songId) async {
    try {
      await songs.doc(songId).delete();

      print('Song with ID "$songId" deleted successfully.');
    } catch (e) {
      print('Error deleting song: $e');
      rethrow;
    }
  }
  //edit
  Future<void> editSong(String songId, String newTitle, String newArtist) async{
    try {
      await songs.doc(songId).update({
        'Title': newTitle,
        'Artist': newArtist,
      });

      print('Song with ID "$songId" updated successfully.');
    } catch (e) {
      print('Error updating song: $e');
      rethrow;
    }
  }








  //add favorites
  Future<void> updateFavoriteStatus(String songUid, bool isFavorite) async{
    await songs.doc(songUid).update({
      'isFavorite': isFavorite,
    });
  }

  Future<List<DocumentSnapshot>> getFavoriteSongs() async{
    QuerySnapshot querySnapshot = await songs
        .where('isFavorite', isEqualTo: true)
        .where('UserEmail', isEqualTo: user?.email)
        .get();
    return querySnapshot.docs;
  }
  Future<bool> getFavoriteStatus(String songUid) async{
    DocumentSnapshot songSnapshot = await songs.doc(songUid).get();
    Map<String, dynamic> data = songSnapshot.data() as Map<String, dynamic>;
    return data['isFavorite'] ?? false;
  }





//recent songs
  Future<void> addRecentlyPlayedSong(
      String songUid,
      String title,
      String artist,
      String fileUrl,
      ) async{
    try {
      String recentSongId = UniqueKey().toString();
      await FirebaseFirestore.instance.collection('RecentSongs').doc(songUid).set({
        'RecentSongId': recentSongId,
        'Title': title,
        'Artist': artist,
        'FileUrl': fileUrl,
        'UserUid': user?.uid,
        'Timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding recently played song: $e");
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecentlyPlayedSongs(){
    return FirebaseFirestore.instance
        .collection('RecentSongs')
        .where('UserUid', isEqualTo: user?.uid)
        .orderBy('Timestamp', descending: true)
        .snapshots();
  }



  //for search paeg
  Future<List<DocumentSnapshot>> getSongByTitle(String title) async{
    try {
      final QuerySnapshot querySnapshot = await songs
          .where('Title', isGreaterThanOrEqualTo: title)
          .where('Title', isLessThan: title + 'z')
          .orderBy('Title')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print("Error getting song by title: $e");
      return [];
    }
  }



  //recommend search
  Future<List<String>> getRecommendations(String query) async{
    try {
      final QuerySnapshot querySnapshot = await songs
          .where('Title', isGreaterThanOrEqualTo: query)
          .where('Title', isLessThan: query + 'z')
          .limit(3)
          .get();

      List<String> recommendations = querySnapshot.docs
          .map((doc) => doc['Title'] as String)
          .toList();

      return recommendations;
    } catch (e) {
      print("Error getting recommendations: $e");
      return [];
    }
  }



  //publics
  Stream<QuerySnapshot<Map<String, dynamic>>> getPublicAlbumsStream() {
    return albums
        .orderBy('TimeStamp', descending: true)
        .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  Stream<List<DocumentSnapshot>> getSongsForPublicAlbum(String albumId){
    return albums
        .where('AlbumId', isEqualTo: albumId)
        .snapshots()
        .map((albumSnapshot){
      if(albumSnapshot.docs.isNotEmpty){
        Map<String, dynamic> albumData = albumSnapshot.docs.first.data() as Map<String, dynamic>;

        if(albumData.containsKey('Songs')){
          List<dynamic> songsRefs = albumData['Songs'] ?? [];
          return songsRefs.cast<DocumentReference>();
        }else{
          print("Error: 'Songs' field not found in the document");
          return [];
        }
      }else{
        return [];
      }
    }).asyncMap((songReferences) async{
      List<DocumentSnapshot> songsData = [];
      for (DocumentReference songRef in songReferences){
        DocumentSnapshot songSnapshot = await songRef.get();
        songsData.add(songSnapshot);
      }
      return songsData;
    });
  }

  //recommends
  Stream<QuerySnapshot> getAllSongsPublicStream(){
    return songs
        .orderBy('Title')
        .snapshots();
  }




//count for dashboard
  Future<int> countUserSongs() async{
    QuerySnapshot querySnapshot = await songs
        .where('UserUid', isEqualTo: user?.uid)
        .get();
    return querySnapshot.size;
  }

  Future<int> countUserAlbums() async{
    QuerySnapshot querySnapshot = await albums
        .where('UserUid', isEqualTo: user?.uid)
        .get();
    return querySnapshot.size;
  }

  Future<int> countAllSongs() async{
    QuerySnapshot querySnapshot = await songs.get();
    return querySnapshot.size;
  }

  Future<int> countAllAlbums() async{
    QuerySnapshot querySnapshot = await albums.get();
    return querySnapshot.size;
  }
}
