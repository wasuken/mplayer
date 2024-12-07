import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentFile;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final List<PlayHistory> playHistory = [];

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

  Future<void> pickAndPlayMusic() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        // 現在再生中の曲があれば停止
        await audioPlayer.stop();

        setState(() {
            currentFile = result.files.single.path;
            isPlaying = false;
        });

        // 新しく選択した曲を再生
        await audioPlayer.play(DeviceFileSource(currentFile!));
        setState(() {
            isPlaying = true;
        });
        playHistory.add(PlayHistory(
            filePath: currentFile!,
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

  String formatTime(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: ListView(
                children: playHistory.map((hist) =>
                  ListTile(
                    title: Text(hist.filePath.split('/').last),
                  )
                ).toList()
              ),
            ),
            Text(
              currentFile != null
              ? 'Currently playing: ${currentFile!.split('/').last}'
              : 'No file selected',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if(currentFile != null)...[
              SizedBox(
                height: 50,
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position)),
                    const Text('/'),
                    Text(formatTime(duration)),
                  ],
                ),
              ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                }
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: pickAndPlayMusic,
                  icon: const Icon(Icons.file_open),
                  label: const Text('Select Music'),
                ),
                const SizedBox(width: 20),
                if (currentFile != null)
                ElevatedButton.icon(
                  onPressed: togglePlayPause,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 履歴を保存するためのクラス
class PlayHistory {
  final String filePath;
  final DateTime playedAt;

  PlayHistory({required this.filePath, required this.playedAt});
}
