import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/program_entity.dart';

class ProgramsLocalDataSource {
  ProgramsLocalDataSource._();

  static final ProgramsLocalDataSource instance = ProgramsLocalDataSource._();

  Future<List<ProgramEntity>> getPrograms() async {
    return const [
      ProgramEntity(
        id: 'al_seerah_al_nabawiyyah',
        titleArabic: 'السيرة النبوية',
        titleEnglish: 'The Prophetic Biography',
        descriptionArabic:
            'برنامج يتناول سيرة النبي محمد ﷺ ومراحل الدعوة وأحداث السيرة النبوية.',
        descriptionEnglish:
            'A program covering the biography of Prophet Muhammad ﷺ, the stages of the message, and events from the Prophetic biography.',
        thumbnailPath: '',
        episodeCount: 0,
        sortOrder: 1,
        isAvailable: true,
      ),

      ProgramEntity(
        id: 'ahdath_al_nihaya_program',
        titleArabic: 'أحداث النهاية',
        titleEnglish: 'Events of the End',
        descriptionArabic: 'برنامج يتناول أشراط الساعة وأحداث آخر الزمان.',
        descriptionEnglish:
            'A program discussing the signs of the Hour and events of the end times.',
        thumbnailPath:
            'assets/videos/thumbnails/programs/ahdath_al_nihaya/cover.jpg',
        episodeCount: 0,
        sortOrder: 2,
        isAvailable: false,
      ),

      ProgramEntity(
        id: 'al_nidaa',
        titleArabic: 'النداء',
        titleEnglish: 'The Call',
        descriptionArabic:
            'برنامج دعوي يتناول مجموعة من الموضوعات الإيمانية والتربوية.',
        descriptionEnglish:
            'A program covering a range of faith-based and educational topics.',
        thumbnailPath: '',
        episodeCount: 0,
        sortOrder: 3,
        isAvailable: false,
      ),
    ];
  }

  Future<List<EpisodeEntity>> getEpisodes({required String programId}) async {
    final episodes = await getAllEpisodes();

    final filteredEpisodes = episodes
        .where(
          (episode) => episode.isAvailable && episode.programId == programId,
        )
        .toList(growable: false);

    filteredEpisodes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return filteredEpisodes;
  }

  Future<EpisodeEntity?> getEpisodeById({required String episodeId}) async {
    final episodes = await getAllEpisodes();

    for (final episode in episodes) {
      if (episode.isAvailable && episode.id == episodeId) {
        return episode;
      }
    }

    return null;
  }

  Future<ProgramEntity?> getProgramById({required String programId}) async {
    final programs = await getPrograms();

    for (final program in programs) {
      if (program.isAvailable && program.id == programId) {
        return program;
      }
    }

    return null;
  }

  Future<List<EpisodeEntity>> getAllEpisodes() async {
    return const [
      EpisodeEntity(
        id: 'ahdath_al_nihaya_episode_1',
        programId: 'ahdath_al_nihaya_program',
        titleArabic: 'المقدمة - الإيمان باليوم الآخر',
        titleEnglish: 'Introduction - Belief in the Last Day',
        descriptionArabic: 'الحلقة الأولى من برنامج أحداث النهاية.',
        descriptionEnglish:
            'The first episode of the Events of the End program.',
        videoPath: 'assets/videos/programs/ahdath_al_nihaya/episode_1.mp4',
        thumbnailPath:
            'assets/videos/thumbnails/programs/ahdath_al_nihaya/episode_1.jpg',
        episodeNumber: 1,
        durationSeconds: 3580,
        sortOrder: 1,
        isAvailable: false,
      ),

      EpisodeEntity(
        id: 'ahdath_al_nihaya_episode_2',
        programId: 'ahdath_al_nihaya_program',
        titleArabic: 'تابع المقدمة - ست علامات بين يدي الساعة',
        titleEnglish: 'Introduction Continued - Six Signs Before the Hour',
        descriptionArabic: 'الحلقة الثانية من برنامج أحداث النهاية.',
        descriptionEnglish:
            'The second episode of the Events of the End program.',
        videoPath: 'assets/videos/programs/ahdath_al_nihaya/episode_2.mp4',
        thumbnailPath:
            'assets/videos/thumbnails/programs/ahdath_al_nihaya/episode_2.jpg',
        episodeNumber: 2,
        durationSeconds: 3359,
        sortOrder: 2,
        isAvailable: false,
      ),
    ];
  }
}
