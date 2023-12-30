import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../database/albumstore.dart';


class CreateAlbumPage extends StatefulWidget {
  const CreateAlbumPage({super.key});

  @override
  _CreateAlbumPageState createState() => _CreateAlbumPageState();
}

class _CreateAlbumPageState extends State<CreateAlbumPage> {
  final TextEditingController _albumNameController = TextEditingController();
  final AlbumDatabase _firestoreDatabase = AlbumDatabase();
  bool _loading = false;

  Future<void> _addAlbum() async{
    try {
      setState(() {
        _loading = true;
      });

      String albumName = _albumNameController.text.trim();

      if(albumName.isNotEmpty){
        String newAlbumName = await _firestoreDatabase.getAvailableAlbumName(albumName);

        await _firestoreDatabase.addAlbum(newAlbumName);

        Fluttertoast.showToast(
          msg: 'Album "$newAlbumName" created successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an album name'),
          ),
        );
      }
    } catch (e) {
      print('Error adding album: $e');
    }finally{
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Album',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _albumNameController,
              decoration: const InputDecoration(
                labelText: 'Album Name',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _addAlbum,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create Album'),
            ),
          ],
        ),
      ),
    );
  }
}
