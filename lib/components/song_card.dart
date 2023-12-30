import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SongCard extends StatefulWidget {
  final String title;
  final String artist;
  final Function onTap;
  final Function onDelete;
  final Function onEdit;
  final String fileUrl;

  const SongCard({
    super.key,
    required this.title,
    required this.artist,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.fileUrl,
  });

  @override
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.fileUrl);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(widget.artist),
      onTap: () => widget.onTap(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        IconButton(
            icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_player.playing) {
                _player.pause();
              } else {
                _player.play();
              }
              setState(() {});
            },
          ),

          SizedBox(width: 8),

          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEdit();
              } else if (value == 'delete') {
                widget.onDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

