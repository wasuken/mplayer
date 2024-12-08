import 'package:flutter/material.dart';
import '../models/play_history.dart';

class PlayHistoryList extends StatelessWidget {
  final Set<PlayHistory> playHistory;

  const PlayHistoryList({
    super.key,
    required this.playHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: ListView(
        children: playHistory
            .map((hist) => ListTile(
                  title: Text(hist.filePath.split('/').last),
                ))
            .toList(),
      ),
    );
  }
}
