import 'package:flutter/material.dart';

class TimeSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;
  final String Function(Duration) formatTime;

  const TimeSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            onSeek(Duration(seconds: value.toInt()));
          },
        ),
      ],
    );
  }
}
