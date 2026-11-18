import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'quran_audio_source.dart';

class QuranAudioCache {
  QuranAudioCache._();

  static final QuranAudioCache instance = QuranAudioCache._();

  Future<File> getAudioFile(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(
        surahNumber,
        'surahNumber',
        'Surah number must be between 1 and 114.',
      );
    }

    final file = await _getLocalFile(surahNumber);

    if (await file.exists()) {
      final length = await file.length();

      if (length > 0) {
        return file;
      }

      await file.delete();
    }

    return _downloadAudio(surahNumber, file);
  }

  Future<bool> isDownloaded(int surahNumber) async {
    final file = await _getLocalFile(surahNumber);

    if (!await file.exists()) {
      return false;
    }

    return await file.length() > 0;
  }

  Future<File> _getLocalFile(int surahNumber) async {
    final directory = await getApplicationDocumentsDirectory();

    final audioDirectory = Directory(
      p.join(directory.path, 'quran', 'audio', 'mohamed_hassan'),
    );

    if (!await audioDirectory.exists()) {
      await audioDirectory.create(recursive: true);
    }

    final fileNumber = surahNumber.toString().padLeft(3, '0');

    return File(p.join(audioDirectory.path, '$fileNumber.mp3'));
  }

  Future<File> _downloadAudio(int surahNumber, File destination) async {
    final url = QuranAudioSource.getSurahUrl(surahNumber);

    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));

      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to download surah audio. '
          'Status code: ${response.statusCode}',
        );
      }

      final tempFile = File('${destination.path}.download');

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final sink = tempFile.openWrite();

      await response.pipe(sink);

      final downloadedLength = await tempFile.length();

      if (downloadedLength <= 0) {
        await tempFile.delete();

        throw const FileSystemException('Downloaded audio file is empty.');
      }

      if (await destination.exists()) {
        await destination.delete();
      }

      return await tempFile.rename(destination.path);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> deleteAudio(int surahNumber) async {
    final file = await _getLocalFile(surahNumber);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clearAllAudio() async {
    final directory = await getApplicationDocumentsDirectory();

    final audioDirectory = Directory(
      p.join(directory.path, 'quran', 'audio', 'mohamed_hassan'),
    );

    if (await audioDirectory.exists()) {
      await audioDirectory.delete(recursive: true);
    }
  }
}
