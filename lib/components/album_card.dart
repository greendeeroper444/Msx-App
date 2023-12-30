import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../database/albumstore.dart';
import '../pages/album_details.dart';

class AlbumCard extends StatelessWidget {
  final String title;
  final String documentId;
  final AlbumDatabase _albumDatabase = AlbumDatabase();

  AlbumCard({
    super.key,
    required this.title,
    required this.documentId,
  });

  Future<void> _editAlbum(BuildContext context) async{
    try {
      String? currentAlbumName = await _albumDatabase.getAlbumName(documentId);

      if(currentAlbumName != null){
        String? newAlbumName = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            TextEditingController controller = TextEditingController(text: currentAlbumName);
            return AlertDialog(
              title: Text('Edit Album'),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, null);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, controller.text.trim());
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );

        if (newAlbumName != null){
          await _albumDatabase.updateAlbum(currentAlbumName, newAlbumName);

          Fluttertoast.showToast(
            msg: 'Album name updated successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error editing album: $e');
    }
  }

  Future<void> _deleteAlbum(BuildContext context) async{
    try {

      String? albumName = await _albumDatabase.getAlbumName(documentId);

      if(albumName != null){
        bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text('Delete Album'),
              content: Text('Are you sure you want to delete the album "$albumName"?'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, false);
                  },
                  child: Text('Cancel'),
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

        if(confirmDelete == true){
          await _albumDatabase.deleteAlbumAndSongs(documentId, albumName);

          Fluttertoast.showToast(
            msg: 'Album "$albumName" deleted successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error deleting album: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailPage(albumId: documentId),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const Icon(Icons.album),
          title: Text(title),
          trailing: PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            onSelected: (String value) {
              if (value == 'edit') {
                // Call the edit function
                _editAlbum(context);
              } else if (value == 'delete') {
                // Call the delete function
                _deleteAlbum(context);
              }
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumDetailPage(albumId: documentId),
              ),
            );
          },
        ),
      ),
    );
  }
}

