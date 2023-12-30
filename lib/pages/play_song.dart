import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../database/albumstore.dart';

class PlaySongPage extends StatefulWidget {
  final String songTitle;
  final String artist;
  final String songUid;
  final String fileUrl;

  const PlaySongPage({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.songUid,
    required this.fileUrl,
  });

  @override
  _PlaySongPageState createState() => _PlaySongPageState();
}

class _PlaySongPageState extends State<PlaySongPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late Timer _timer;
  double _sliderValue = 0.0;
  bool _loopModeSelected = false;
  bool _shuffleModeSelected = false;
  bool _isFavorite = false;
  double _sliderMaxValue = 0.0;

  @override
  void initState(){
    super.initState();
    _initAudioPlayer();
    _timer = Timer.periodic(Duration(milliseconds: 500), _updateProgress);
    _loadFavoriteStatus();
  }

  void _initAudioPlayer() async{
    await _audioPlayer.setUrl(widget.fileUrl);
    _audioPlayer.playerStateStream.listen((playerState){
      setState((){
        _isPlaying = _audioPlayer.playing;

        if(_audioPlayer.position == _audioPlayer.duration){
          _onComplete();
        }
      });
    });
    _audioPlayer.positionStream.listen((position){
      setState((){
        if (_audioPlayer.duration != null){
          _sliderMaxValue = _audioPlayer.duration!.inMilliseconds.toDouble();
          _sliderValue = position.inMilliseconds.toDouble();
        }
      });
    });
  }

  void _onComplete(){

    AlbumDatabase().addRecentlyPlayedSong(
      widget.songUid,
      widget.songTitle,
      widget.artist,
      widget.fileUrl,
    );

    if(_audioPlayer.hasNext){
      _seekToNext();
    }else {
      _audioPlayer.stop();
    }
  }



  void _updateProgress(Timer timer){
    final position = _audioPlayer.position;
    final duration = _audioPlayer.duration;

    if(position != null && duration != null){
      setState((){
        _sliderValue = position.inMilliseconds.toDouble();
      });
    }
  }

  void _seekToNext(){
    if(_audioPlayer.hasNext){
      _audioPlayer.seekToNext();
    }
  }


  void _seekToPrevious(){
    _audioPlayer.seekToPrevious();
  }

  void _seekToPosition(double value){
    if(_audioPlayer.duration != null){
      double validValue = value.clamp(0.0, _audioPlayer.duration!.inMilliseconds.toDouble());
      _audioPlayer.seek(Duration(milliseconds: validValue.toInt()));
    }
  }

  void _setLoopMode() async{
    await _audioPlayer.setLoopMode(
        _loopModeSelected ? LoopMode.off : LoopMode.all);
    setState((){
      _loopModeSelected = !_loopModeSelected;
      _shuffleModeSelected = false;
    });
  }

  void _setShuffleMode() async{
    await _audioPlayer.setShuffleModeEnabled(
        _shuffleModeSelected ? false : true);
    setState((){
      _loopModeSelected = false;
      _shuffleModeSelected = !_shuffleModeSelected;
    });
  }


  //favorite
  void _loadFavoriteStatus() async{
    bool isFavorite = await AlbumDatabase().getFavoriteStatus(widget.songUid);
    setState((){
      _isFavorite = isFavorite;
    });
  }


  void _toggleFavorite() async{
    setState((){
      _isFavorite = !_isFavorite;
    });

    await AlbumDatabase().updateFavoriteStatus(widget.songUid, _isFavorite);
  }

  @override
  void dispose(){
    _audioPlayer.dispose();
    _timer.cancel();

    //Save the song as recently played
    AlbumDatabase().addRecentlyPlayedSong(
      widget.songUid,
      widget.songTitle,
      widget.artist,
      widget.fileUrl,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.songTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              'by ' + widget.artist,
              style: const TextStyle(
                  fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                Icons.favorite,
                color: _isFavorite ? Colors.red : null,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 148, 87, 235),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child:const  Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Slider(
              value: _sliderValue.clamp(0.0, _sliderMaxValue),
              min: 0.0,
              max: _sliderMaxValue,
              onChanged: _seekToPosition,
            ),
            const SizedBox(height: 20),

            StreamBuilder<Duration?>(
              stream: _audioPlayer.positionStream,
              builder: (context, positionSnapshot){
                final position = positionSnapshot.data ?? Duration.zero;
                final duration = _audioPlayer.duration;

                String formattedPosition =
                    '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}';
                String formattedDuration = duration != null
                    ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
                    : '00:00';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedPosition,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      formattedDuration,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                );

              },
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _seekToPrevious,
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: (){
                    if(_audioPlayer.playing){
                      _audioPlayer.pause();
                    }else{
                      _audioPlayer.play();
                    }
                  },
                  icon: Icon(
                    _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                    size: 48,
                  ),
                ),
                IconButton(
                  onPressed: _seekToNext,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _setLoopMode,
                  icon: Text(
                    'Loop',
                    style: TextStyle(
                      fontWeight: _loopModeSelected ? FontWeight.bold : FontWeight.normal,
                      color: _loopModeSelected ? const Color.fromARGB(255, 148, 87, 235) : null,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _setShuffleMode,
                  icon: Text(
                    'Shuffle',
                    style: TextStyle(
                      fontWeight: _shuffleModeSelected ? FontWeight.bold : FontWeight.normal,
                      color: _shuffleModeSelected ? const Color.fromARGB(255, 148, 87, 235) : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
