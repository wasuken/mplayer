import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/play_history.dart';
import '../widgets/play_history_list.dart';
import '../widgets/player_controls.dart';
import '../widgets/time_slider.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentFile;
  String? currentOriginalFile;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final Set<PlayHistory> playHistory = {};

  @override
  void initState() {
    super.initState();
    audioPlayer.onPositionChanged.listen((updatedPosition) {
      setState(() {
        position = updatedPosition;
      });
    });
    audioPlayer.onDurationChanged.listen((updatedDuration) {
      setState(() {
        duration = updatedDuration;
      });
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> pickAndPlayMusic() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        await audioPlayer.stop();
        setState(() {
          currentFile = result.files.single.path;
          currentOriginalFile = result.files.single.name;
          isPlaying = false;
        });

        await audioPlayer.play(DeviceFileSource(currentFile!));
        setState(() {
          isPlaying = true;
        });
        playHistory.add(PlayHistory(
          filePath: currentFile!,
          originalFilePath: currentOriginalFile!,
          playedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (currentFile == null) return;

    try {
      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.resume();
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Music Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayHistoryList(playHistory: playHistory),
            Text(
              currentFile != null
                  ? 'Currently playing: ${currentFile!.split('/').last}'
                  : 'No file selected',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (currentFile != null) ...[
              TimeSlider(
                position: position,
                duration: duration,
                onSeek: (position) async => await audioPlayer.seek(position),
                formatTime: formatTime,
              ),
              const SizedBox(height: 20),
            ],
            PlayerControls(
              onPickMusic: pickAndPlayMusic,
              onTogglePlayPause: togglePlayPause,
              isPlaying: isPlaying,
              hasFile: currentFile != null,
            ),
          ],
        ),
      ),
    );
  }
}
