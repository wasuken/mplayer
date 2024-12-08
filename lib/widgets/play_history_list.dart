import 'package:flutter/material.dart';
import '../models/play_history.dart';

class PlayHistoryList extends StatelessWidget {
  final Set<PlayHistory> playHistory;
  final Function(PlayHistory) onHistoryTap;

  const PlayHistoryList({
    super.key,
    required this.playHistory,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: ListView(
        children: playHistory
            .map((hist) => ListTile(
                  title: Text(hist.filePath.split('/').last),
                  onTap: () => onHistoryTap(hist),
                  leading: const Icon(Icons.music_note),
                  hoverColor: Colors.blue.withOpacity(0.1),
                ))
            .toList(),
      ),
    );
  }
}
