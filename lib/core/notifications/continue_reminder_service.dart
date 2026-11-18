import 'notification_service.dart';

class ContinueReminderService {
  ContinueReminderService._();

  static final ContinueReminderService instance = ContinueReminderService._();

  static const int _bookReminderId = 2001;
  static const int _programReminderId = 2002;
  static const int _quranReminderId = 2003;

  static const Duration defaultReminderDelay = Duration(hours: 24);

  Future<void> scheduleBookReminder({
    required String bookId,
    required int pageNumber,
    required String title,
    required String body,
    Duration delay = defaultReminderDelay,
  }) async {
    if (bookId.trim().isEmpty || pageNumber <= 1) {
      await cancelBookReminder();
      return;
    }

    await NotificationService.instance.scheduleContinueReminder(
      id: _bookReminderId,
      title: title,
      body: body,
      delay: delay,
      data: {'type': 'book', 'id': bookId, 'page': pageNumber.toString()},
    );
  }

  Future<void> scheduleProgramReminder({
    required String episodeId,
    required int positionSeconds,
    required String title,
    required String body,
    Duration delay = defaultReminderDelay,
  }) async {
    if (episodeId.trim().isEmpty || positionSeconds <= 0) {
      await cancelProgramReminder();
      return;
    }

    await NotificationService.instance.scheduleContinueReminder(
      id: _programReminderId,
      title: title,
      body: body,
      delay: delay,
      data: {
        'type': 'episode',
        'id': episodeId,
        'position': positionSeconds.toString(),
      },
    );
  }

  Future<void> scheduleQuranReminder({
    required int pageNumber,
    required int surahNumber,
    required String title,
    required String body,
    Duration delay = defaultReminderDelay,
  }) async {
    if (pageNumber < 1 ||
        pageNumber > 604 ||
        surahNumber < 1 ||
        surahNumber > 114) {
      await cancelQuranReminder();
      return;
    }

    await NotificationService.instance.scheduleContinueReminder(
      id: _quranReminderId,
      title: title,
      body: body,
      delay: delay,
      data: {
        'type': 'quran',
        'page': pageNumber.toString(),
        'surah': surahNumber.toString(),
      },
    );
  }

  Future<void> cancelBookReminder() {
    return NotificationService.instance.cancelLocalNotification(
      _bookReminderId,
    );
  }

  Future<void> cancelProgramReminder() {
    return NotificationService.instance.cancelLocalNotification(
      _programReminderId,
    );
  }

  Future<void> cancelQuranReminder() {
    return NotificationService.instance.cancelLocalNotification(
      _quranReminderId,
    );
  }

  Future<void> cancelAll() {
    return NotificationService.instance.cancelLocalNotifications(const [
      _bookReminderId,
      _programReminderId,
      _quranReminderId,
    ]);
  }
}
