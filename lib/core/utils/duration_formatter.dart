String formatDuration(Duration duration, {bool alwaysShowHours = false}) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (alwaysShowHours || hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatDurationSeconds(int totalSeconds, {bool alwaysShowHours = false}) {
  return formatDuration(
    Duration(seconds: totalSeconds),
    alwaysShowHours: alwaysShowHours,
  );
}
