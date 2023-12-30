import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../database/albumstore.dart';

class UploadMusicPage extends StatefulWidget {
  final String albumId;


  const UploadMusicPage({
    super.key,
    required this.albumId
  });

  @override
  _UploadMusicPageState createState() => _UploadMusicPageState();
}

class _UploadMusicPageState extends State<UploadMusicPage> {
  final AlbumDatabase _firestoreDatabase = AlbumDatabase();
  File? _selectedFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  late Future<String?> _albumNameFuture;
  bool _uploading = false;

  @override
  void initState(){
    super.initState();
    _albumNameFuture = _fetchAlbumName();
  }

  Future<String?> _fetchAlbumName() async{
    try {
      final String? name = await _firestoreDatabase.getAlbumName(widget.albumId);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: _albumNameFuture,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }else if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }else{
              return Text('${snapshot.data ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async{
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(
                    type: FileType.audio,
                    allowMultiple: false,
                  );

                  if(result != null){
                    setState((){
                      _selectedFile = File(result.files.single.path!);
                    });
                  }else {
                    Fluttertoast.showToast(
                      msg: "Please select a music file.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                child: const Text('Select Music File'),
              ),

              const SizedBox(height: 16),

              _selectedFile != null
                  ? Text('Selected File: ${_selectedFile!.path}')
                  : Container(),

              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Song Title'),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async{
                  if(_selectedFile == null){
                    Fluttertoast.showToast(
                      msg: "Please select a music file and provide title/artist.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                    return;
                  }

                  setState((){
                    _uploading = true;
                  });

                  String title = _titleController.text;
                  String artist = _artistController.text;

                  title = title.isNotEmpty ? title : 'Unknown';
                  artist = artist.isNotEmpty ? artist : 'Unknown';

                  //extract file name from the path
                  String fileName = _selectedFile!.path!.split('/').last;

                  //construct storage path
                  String storagePath = '${widget.albumId}/$fileName';

                  //upload music file to storage
                  String storageUrl =
                  await _uploadFileToStorage(_selectedFile!, storagePath);

                  //add song details to Firestore with the actual file URL
                  await _uploadSongDetailsToFirestore(title, artist, storageUrl);

                  //update song details in Firestore with the storage URL
                  await _firestoreDatabase.updateSongStorageUrl(
                    widget.albumId,
                    title,
                    artist,
                    storageUrl,
                  );

                  //clear text controllers and selected file after upload
                  _titleController.clear();
                  _artistController.clear();
                  setState(() {
                    _selectedFile = null;
                    _uploading = false;
                  });

                  Fluttertoast.showToast(
                    msg: 'Song "$title" added successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );

                  Navigator.pop(context);
                },
                child: _uploading ? const CircularProgressIndicator() : const Text('Upload Music'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadSongDetailsToFirestore(String title, String artist, String fileUrl) async{
    try {
      String uniqueSongTitle = await _firestoreDatabase.getAvailableSongTitle(widget.albumId, title);

      //Pass the unique song title to addSongToAlbum method
      await _firestoreDatabase.addSongToAlbum(
        widget.albumId,
        uniqueSongTitle,
        artist,
        fileUrl,
      );
    } catch (e) {
      print('Error adding song details to Firestore: $e');
    }
  }


  Future<String> _uploadFileToStorage(File file, String storagePath) async{
    try {
      Reference ref = FirebaseStorage.instance.ref().child(storagePath);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file to storage: $e');
      return '';
    }
  }
}
