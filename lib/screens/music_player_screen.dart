import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  String _currentSongName = '再生中の曲はありません';

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getFileName(String path) {
    return path.split('/').last.replaceAll(RegExp(r'\.(mp3|wav|m4a)$'), '');
  }

  Future<void> _pickMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _playlist.addAll(
          result.paths.where((path) => path != null).map((path) => path!),
        );
      });

      if (!_isPlaying && _playlist.isNotEmpty) {
        _playMusic(_playlist[0]);
      }
    }
  }

  Future<void> _playMusic(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
        _currentSongName = _getFileName(path);
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      });
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  void _playNext() {
    if (_playlist.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    });
    _playMusic(_playlist[_currentIndex]);
  }

  void _playPrevious() {
    if (_playlist.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    });
    _playMusic(_playlist[_currentIndex]);
  }

  void _togglePlay() async {
    if (_playlist.isEmpty) return;
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      await _audioPlayer.play();
    } else {
      await _audioPlayer.pause();
    }
  }

  void _seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Row(children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("PlayList",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))
          ]),
          // Playlist
          Expanded(
            child: ListView.builder(
              itemCount: _playlist.length,
              itemBuilder: (context, index) {
                final fileName = _getFileName(_playlist[index]);
                return ListTile(
                  title: Text(fileName),
                  selected: index == _currentIndex,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    _playMusic(_playlist[index]);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.music_note),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentSongName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StreamBuilder<Duration?>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                            ),
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble(),
                            max: (_audioPlayer.duration?.inMilliseconds ?? 1)
                                .toDouble(),
                            onChanged: (value) {
                              _seekTo(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(_audioPlayer.duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _playlist.isEmpty ? null : _playPrevious,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _playlist.isEmpty ? null : _togglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _playlist.isEmpty ? null : _playNext,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _pickMusic,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
