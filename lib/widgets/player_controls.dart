import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final VoidCallback onPickMusic;
  final VoidCallback? onTogglePlayPause;
  final bool isPlaying;
  final bool hasFile;

  const PlayerControls({
    super.key,
    required this.onPickMusic,
    required this.onTogglePlayPause,
    required this.isPlaying,
    required this.hasFile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onPickMusic,
          icon: const Icon(Icons.file_open),
          label: const Text('Select Music'),
        ),
        const SizedBox(width: 20),
        if (hasFile)
          ElevatedButton.icon(
            onPressed: onTogglePlayPause,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(isPlaying ? 'Pause' : 'Play'),
          ),
      ],
    );
  }
}
