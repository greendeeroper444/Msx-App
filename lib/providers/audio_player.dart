// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import '../database/albumstore.dart';
//
// class AudioPlayerProvider extends ChangeNotifier {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;
//   Timer? _timer;
//   double _sliderValue = 0.0;
//   bool _loopModeSelected = false;
//   bool _shuffleModeSelected = false;
//   double _sliderMaxValue = 0.0;
//
//   AudioPlayer get audioPlayer => _audioPlayer;
//   bool get isPlaying => _isPlaying;
//   Timer? get timer => _timer;
//
//   set timer(Timer? value) {
//     _timer = value;
//   }
//
//   void initAudioPlayer(String fileUrl) async {
//     await _audioPlayer.setUrl(fileUrl);
//
//     _audioPlayer.playerStateStream.listen((playerState) {
//       _isPlaying = _audioPlayer.playing;
//       if (_audioPlayer.position == _audioPlayer.duration) {
//         _onComplete();
//       }
//       notifyListeners();
//     });
//
//     _audioPlayer.positionStream.listen((position) {
//       if (_audioPlayer.duration != null) {
//         _sliderMaxValue = _audioPlayer.duration!.inMilliseconds.toDouble();
//         _sliderValue = position.inMilliseconds.toDouble();
//       }
//       notifyListeners();
//     });
//   }
//
//   void playPause() {
//     if (_audioPlayer.playing) {
//       _audioPlayer.pause();
//     } else {
//       _audioPlayer.play();
//     }
//     _isPlaying = _audioPlayer.playing;
//     notifyListeners();
//   }
//
//   void seekToNext() {
//     if (_audioPlayer.hasNext) {
//       _audioPlayer.seekToNext();
//     }
//   }
//
//   void seekToPrevious() {
//     _audioPlayer.seekToPrevious();
//   }
//
//   void seekToPosition(double value) {
//     if (_audioPlayer.duration != null) {
//       double validValue = value.clamp(
//         0.0,
//         _audioPlayer.duration!.inMilliseconds.toDouble(),
//       );
//       _audioPlayer.seek(Duration(milliseconds: validValue.toInt()));
//     }
//   }
//
//   void setLoopMode() async {
//     await _audioPlayer.setLoopMode(
//       _loopModeSelected ? LoopMode.off : LoopMode.all,
//     );
//     _loopModeSelected = !_loopModeSelected;
//     _shuffleModeSelected = false;
//     notifyListeners();
//   }
//
//   void setShuffleMode() async {
//     await _audioPlayer.setShuffleModeEnabled(
//       _shuffleModeSelected ? false : true,
//     );
//     _loopModeSelected = false;
//     _shuffleModeSelected = !_shuffleModeSelected;
//     notifyListeners();
//   }
//
//   void _onComplete() {
//     // Save the song as recently played
//     FirestoreDatabase().addRecentlyPlayedSong(
//       widget.songUid, // Assuming this is the unique identifier for the song
//       widget.songTitle,
//       widget.artist,
//     );
//
//     // Seek to the next song if available, otherwise stop playback
//     if (_audioPlayer.hasNext) {
//       seekToNext();
//     } else {
//       _audioPlayer.stop();
//     }
//   }
//
//
//   void updateProgress(Timer timer) {
//     final position = _audioPlayer.position;
//     final duration = _audioPlayer.duration;
//
//     if (position != null && duration != null) {
//       _sliderValue = position.inMilliseconds.toDouble();
//     }
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
// }
