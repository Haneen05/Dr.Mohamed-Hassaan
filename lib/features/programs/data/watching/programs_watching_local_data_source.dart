import 'package:shared_preferences/shared_preferences.dart';

class ProgramsWatchingRecord {
  const ProgramsWatchingRecord({
    required this.episodeId,
    required this.positionSeconds,
  });

  final String episodeId;
  final int positionSeconds;
}

class ProgramsWatchingLocalDataSource {
  ProgramsWatchingLocalDataSource._();

  static final ProgramsWatchingLocalDataSource instance =
      ProgramsWatchingLocalDataSource._();

  static const String _lastEpisodeIdKey = 'programs_last_watched_episode_id';

  String _positionKey(String episodeId) {
    return 'program_episode_position_$episodeId';
  }

  Future<ProgramsWatchingRecord?> getLastWatching() async {
    final prefs = await SharedPreferences.getInstance();

    final episodeId = prefs.getString(_lastEpisodeIdKey);

    if (episodeId == null || episodeId.trim().isEmpty) {
      return null;
    }

    final position = prefs.getInt(_positionKey(episodeId)) ?? 0;

    return ProgramsWatchingRecord(
      episodeId: episodeId,
      positionSeconds: position > 0 ? position : 0,
    );
  }

  Future<int> getEpisodePosition({required String episodeId}) async {
    final prefs = await SharedPreferences.getInstance();

    final position = prefs.getInt(_positionKey(episodeId)) ?? 0;

    return position > 0 ? position : 0;
  }

  Future<void> saveWatching({
    required String episodeId,
    required int positionSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final position = positionSeconds > 0 ? positionSeconds : 0;

    await prefs.setInt(_positionKey(episodeId), position);

    await prefs.setString(_lastEpisodeIdKey, episodeId);
  }

  Future<void> clearEpisode({required String episodeId}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_positionKey(episodeId));

    final lastEpisodeId = prefs.getString(_lastEpisodeIdKey);

    if (lastEpisodeId == episodeId) {
      await prefs.remove(_lastEpisodeIdKey);
    }
  }
}
