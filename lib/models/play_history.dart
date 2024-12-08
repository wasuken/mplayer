class PlayHistory {
  final String originalFilePath;
  final String filePath;
  final DateTime playedAt;

  PlayHistory(
      {required this.filePath,
      required this.playedAt,
      required this.originalFilePath});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayHistory &&
          runtimeType == other.runtimeType &&
          originalFilePath == other.originalFilePath;

  @override
  int get hashCode => originalFilePath.hashCode;
}
