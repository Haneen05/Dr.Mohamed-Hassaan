import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'books': 'Books',
      'videos': 'Videos',
      'profile': 'Profile',
      'quran': 'Quran',

      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',

      'viewAll': 'View All',
      'showLess': 'Show Less',
      'tryAgain': 'Try Again',

      'welcomeBack': 'Welcome Back',
      'assalamuAlaikum': 'Assalamu Alaikum',
      'explore': 'Explore',
      'recitations': 'Recitations',
      'lectures': 'Lectures',
      'featuredContent': 'Featured Content',
      'latestLecture': 'Latest Lecture',

      'readBooks': 'Read books',
      'watchLectures': 'Watch lectures',
      'readExploreQuran': 'Read & explore Quran',
      'listenToQuran': 'Listen to Quran',
      'listenLearn': 'Listen & learn',

      'mainSections': 'Main Sections',
      'latestContent': 'Latest Content',
      'searchApp': 'Search in the app...',
      'startSearching': 'Type to search books, programs, episodes, and Surahs.',
      'noSearchResults': 'No results found.',
      'audioLessonsComingSoon': 'Audio lessons are coming soon.',
      'fatwasComingSoon': 'Fatwas are coming soon.',
      'fatwas': 'Fatwas',
      'quranTafsir': 'Quran Tafsir',
      'audioLessons': 'Audio Lessons',
      'allContent': 'View All',
      'bookCollection': 'Browse all books',
      'videoLectures': 'Lectures and lessons',
      'quranRecitations': 'Read and explore Quran',
      'fatwaCollection': 'Fatwa collection',
      'ayahTafsir': 'Tafsir of Quran verses',
      'audioLectures': 'Lessons and lectures',

      'surahs': 'Surahs',
      'ayahs': 'Ayahs',
      'tafsir': 'Tafsir',
      'listenWhileReading': 'Listen while reading',
      'bookmarks': 'Bookmarks',
      'savedPages': 'Saved Pages',
      'startPage': 'Start Page',

      'meccan': 'Meccan',
      'medinan': 'Medinan',

      'page': 'Page',
      'continueReading': 'Continue Reading',

      'bookmarkSaved': 'Page saved',
      'bookmarkRemoved': 'Page removed from bookmarks',
      'bookmarkError': 'Unable to update bookmark',

      'noBookmarks': 'No saved pages',
      'noBookmarksSubtitle':
          'You can save any Mushaf page using the bookmark icon.',

      'somethingWentWrong': 'Something went wrong',
      'noContentYet': 'No content yet',

      'sheikhTitle': 'Sheikh Dr.',
      'scholarName': 'Mohamed Hassan',
      'authTagline': 'Read • Listen • Learn',

      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'confirmPassword': 'Confirm Password',

      'enterEmail': 'Enter your email',
      'enterPassword': 'Enter your password',
      'enterName': 'Enter your name',
      'confirmYourPassword': 'Confirm your password',

      'signUp': 'Sign Up',
      'logIn': 'Log In',

      'loginTitle': 'Welcome Back',
      'loginSubtitle': 'Login to continue your journey',

      'forgotPassword': 'Forgot Password?',

      'dontHaveAccount': "Don't have an account?",

      'loginEmptyFields': 'Please enter your email and password',

      'signupTitle': 'Create Account',
      'signupSubtitle': 'Create your account to continue',

      'alreadyHaveAccount': 'Already have an account?',

      'signupEmptyFields': 'Please fill in all fields',

      'passwordsDoNotMatch': 'Passwords do not match',

      'accountCreatedSuccessfully':
          'Account created successfully. Please login.',
      'authEmailAlreadyInUse': 'This email is already registered.',
      'authInvalidEmail': 'Please enter a valid email address.',
      'authWeakPassword': 'Password is too weak.',
      'authUserNotFound': 'No account was found with this email.',
      'authInvalidCredential': 'Incorrect email or password.',
      'authNetworkError': 'Please check your internet connection.',
      'authTooManyRequests': 'Too many attempts. Please try again later.',
      'authServerError': 'A server error occurred. Please try again.',
      'authUnknownError': 'Something went wrong. Please try again.',

      'latestDhikrTitle': 'The Virtue of Remembering Allah',
      'faithLectures': 'Faith Lectures',

      'baqarahTafsirTitle': 'Tafsir of Surah Al-Baqarah',
      'quranTafsirCategory': 'Quran Tafsir',
      'ayahsOneToTen': 'Ayahs 1 - 10',

      'maintainPrayerTitle': 'How to Maintain Prayer',
      'audioLessonsCategory': 'Audio Lessons',

      'quranTitle': 'The Holy Quran',
      'quranSubtitle': 'Read, listen and explore the Tafsir of the Quran.',
      'searchSurah': 'Search for a Surah...',
      'noSurahsYet': 'No Surahs yet',
      'quranEmptySubtitle': 'Quran content will appear here when it is added.',

      'recitationUnavailable': 'Recitation is not available yet.',
      'unableToPlayRecitation': 'Unable to play this recitation.',
      'tafsirWillBeAdded': 'Tafsir will be added later.',

      'menu': 'Menu',
      'surahInformation': 'Surah Information',
      'listen': 'Listen',
      'ayahCount': 'Ayah Count',
      'surahNumber': 'Surah Number',
      'revelationType': 'Revelation Type',
      'tafsirSaadi': 'Tafsir Al-Saadi',
      'tafsirIbnKathir': 'Tafsir Ibn Kathir',

      'tafsirJalalayn': 'Tafsir Al-Jalalayn',

      'settings': 'Settings',
      'chooseLanguage': 'Choose the application language',

      'appearance': 'Appearance',
      'chooseAppearance': 'Choose the application appearance',
      'systemTheme': 'System',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemThemeSubtitle': 'Use device settings',
      'lightThemeSubtitle': 'Always use light mode',
      'darkThemeSubtitle': 'Always use dark mode',
      'mushafReadingMode': 'Mushaf Reading',
      'chooseMushafReadingMode': 'Choose the Mushaf reading appearance',
      'normalReadingMode': 'Normal',
      'normalReadingModeSubtitle': 'Use the standard Mushaf colors',
      'nightReadingMode': 'Night',
      'nightReadingModeSubtitle': 'Use a dark background for reading',
      'bookmarkLoadError': 'Unable to load saved pages',
      'addBookmark': 'Add bookmark',
      'removeBookmark': 'Remove bookmark',

      'tafsirLoadError': 'Unable to load Tafsir',
      'noTafsir': 'No Tafsir available',
      'noTafsirForSurah': 'No Tafsir data was found for this Surah.',
      'noTafsirForAyah': 'No Tafsir is available for this Ayah.',
      'readBook': 'Read Book',

      'aboutBook': 'About This Book',
      'pages': 'Pages',
      'bookDescriptionUnavailable':
          'No description is available for this book yet.',
      'pageCountUnavailable': 'Page count unavailable',
      'publisherUnavailable': 'Publisher unavailable',

      'booksTitle': 'Sheikh\'s Books',
      'booksSubtitle': 'Books and writings by Sheikh Mohamed Hassan',

      'searchBooks': 'Search books...',
      'allBooks': 'All Books',
      'book': 'Book',
      'booksCount': 'Books',

      'featuredBook': 'Featured Book',
      'publisher': 'Publisher',

      'noBooksYet': 'No books yet',
      'booksEmptySubtitle': 'Books will appear here when they are added.',

      'booksLoadError': 'Unable to load books',

      'allCategory': 'All',
      'aqeedahCategory': 'Aqeedah',
      'quranTafsirCategoryBooks': 'Quran & Tafsir',
      'seerahHistoryCategory': 'Seerah & History',
      'hadithCategory': 'Hadith & Sunnah',
      'fiqhCategory': 'Fiqh',
      'dawahCategory': 'Dawah',
      'educationEthicsCategory': 'Education & Ethics',
      'akhirahCategory': 'Akhirah',
      'knowledgeThroughBooks': 'Knowledge Through Books',
      'booksIntro': 'Explore books and writings by Sheikh Mohamed Hassan',
      'pageCount': 'Pages',
      'bookUnavailable': 'This book is not available for reading yet.',
      'goToPage': 'Go to Page',
      'go': 'Go',
      'cancel': 'Cancel',
      'booksHeaderTitle': 'Books',

      'programsTitle': 'Programs',
      'programsSubtitle':
          'Programs and episode series by Sheikh Mohamed Hassan',
      'searchPrograms': 'Search programs',
      'episodes': 'Episodes',
      'programsLoadError': 'Something went wrong while loading programs',
      'noProgramsYet': 'No programs yet',
      'programsEmptySubtitle': 'Programs will appear here when they are added.',
      'noProgramsFound': 'No results found',
      'programEpisodes': 'Program Episodes',
      'episode': 'Episode',
      'noEpisodesYet': 'No episodes yet',
      'episodesEmptySubtitle':
          'Program episodes will appear here when they are added.',
      'episodesLoadError': 'Something went wrong while loading episodes',
      'programsHomeSubtitle': 'Programs and series',
      'sermonsTitle': 'Sermons',
      'sermonsSubtitle': 'Sermons and lectures',

      'sermonsPageSubtitle': 'Sermons and lectures on different topics',
      'searchSermons': 'Search sermons',
      'sermonsLoadError': 'Something went wrong while loading sermons',
      'noSermonsYet': 'No sermons yet',
      'sermonsEmptySubtitle': 'Sermons will appear here when they are added.',
      'noSermonsFound': 'No results found',
      'heartSoftenersCategory': 'Heart Softeners',
      'repentanceCategory': 'Repentance',
      'fitanCategory': 'Trials',
      'familySocietyCategory': 'Family & Society',
      'seerahCategory': 'Seerah',
      'occasionsCategory': 'Occasions',
      'forgotPasswordTitle': 'Reset Password',
      'forgotPasswordSubtitle':
          'Enter your email and we will send you a password reset link.',
      'sendResetLink': 'Send Reset Link',
      'resetEmailSent': 'Password reset link has been sent to your email.',
      'resetPasswordEmptyEmail': 'Please enter your email address.',
      'logout': 'Log Out',
      'profileEmailUnavailable': 'Email unavailable',
      'profileNameUnavailable': 'Name unavailable',
      'profileLoadError': 'Unable to load profile',
      'profileLoadErrorSubtitle':
          'Your profile information could not be loaded.',

      'notifications': 'Notifications',
      'notificationsSubtitle': 'Your latest updates and reminders',
      'noNotifications': 'No notifications yet',
      'noNotificationsSubtitle': 'New updates and reminders will appear here.',
      'markAllAsRead': 'Mark all as read',
      'clearNotifications': 'Clear notifications',
      'clearNotificationsTitle': 'Clear notifications?',
      'clearNotificationsMessage': 'All saved notifications will be removed.',
      'clear': 'Clear',
      'justNow': 'Just now',
      'minutesAgo': 'min ago',
      'hoursAgo': 'hr ago',
      'daysAgo': 'days ago',

      'continueBookReminderTitle': 'Continue reading',
      'continueBookReminderBody': 'Continue your book from where you stopped.',
      'continueProgramReminderTitle': 'Continue watching',
      'continueProgramReminderBody':
          'Continue your episode from where you stopped.',
      'continueQuranReminderTitle': 'Continue reading the Quran',
      'continueQuranReminderBody':
          'Continue your Quran reading from where you stopped.',

      'fullScreen': 'Full Screen',
      'mushafPageLoadError': 'Unable to load the Mushaf page',
      'mushafPageEmpty': 'No data is available for this page',
    },

    'ar': {
      'home': 'الرئيسية',
      'books': 'الكتب',
      'videos': 'الفيديوهات',
      'profile': 'الملف الشخصي',
      'quran': 'القرآن الكريم',

      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',

      'viewAll': 'عرض الكل',
      'showLess': 'عرض أقل',
      'tryAgain': 'حاول مرة أخرى',

      'welcomeBack': 'مرحبًا بعودتك',
      'assalamuAlaikum': 'السلام عليكم',
      'explore': 'استكشف',
      'recitations': 'التلاوات',
      'lectures': 'الدروس',
      'featuredContent': 'محتوى مميز',
      'latestLecture': 'أحدث درس',

      'readBooks': 'اقرأ الكتب',
      'watchLectures': 'شاهد الدروس',
      'readExploreQuran': 'اقرأ واستكشف القرآن',
      'listenToQuran': 'استمع إلى القرآن',
      'listenLearn': 'استمع وتعلم',

      'mainSections': 'الأقسام الرئيسية',
      'latestContent': 'أحدث المحتويات',
      'searchApp': 'ابحث في التطبيق...',
      'startSearching': 'اكتبي للبحث في الكتب والبرامج والحلقات والسور.',
      'noSearchResults': 'لا توجد نتائج.',
      'audioLessonsComingSoon': 'الدروس الصوتية ستُضاف قريبًا.',
      'fatwasComingSoon': 'الفتاوى ستُضاف قريبًا.',
      'fatwas': 'فتاوى',
      'quranTafsir': 'تفسير القرآن',
      'audioLessons': 'دروس صوتية',
      'allContent': 'عرض الكل',
      'bookCollection': 'عرض جميع الكتب',
      'videoLectures': 'المحاضرات والدروس',
      'quranRecitations': 'اقرأ واستكشف القرآن',
      'fatwaCollection': 'مجموعة الفتاوى',
      'ayahTafsir': 'تفسير آيات القرآن',
      'audioLectures': 'دروس ومحاضرات',

      'surahs': 'السور',
      'ayahs': 'الآيات',
      'tafsir': 'التفسير',
      'listenWhileReading': 'استمع أثناء القراءة',
      'bookmarks': 'العلامات المحفوظة',
      'savedPages': 'الصفحات المحفوظة',
      'startPage': 'صفحة البداية',

      'meccan': 'مكية',
      'medinan': 'مدنية',

      'page': 'صفحة',
      'continueReading': 'متابعة القراءة',

      'bookmarkSaved': 'تم حفظ الصفحة',
      'bookmarkRemoved': 'تم حذف الصفحة من العلامات',
      'bookmarkError': 'حدث خطأ أثناء تحديث العلامة',

      'noBookmarks': 'لا توجد صفحات محفوظة',
      'noBookmarksSubtitle':
          'يمكنك حفظ أي صفحة من المصحف باستخدام علامة الحفظ.',

      'somethingWentWrong': 'حدث خطأ',
      'noContentYet': 'لا يوجد محتوى بعد',

      'sheikhTitle': 'الشيخ الدكتور',
      'scholarName': 'محمد حسان',
      'authTagline': 'اقرأ • استمع • تعلم',

      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'name': 'الاسم',
      'confirmPassword': 'تأكيد كلمة المرور',

      'enterEmail': 'أدخل بريدك الإلكتروني',
      'enterPassword': 'أدخل كلمة المرور',
      'enterName': 'أدخل اسمك',
      'confirmYourPassword': 'أعد إدخال كلمة المرور',

      'signUp': 'إنشاء حساب',
      'logIn': 'تسجيل الدخول',

      'loginTitle': 'مرحبًا بعودتك',
      'loginSubtitle': 'سجّل الدخول للمتابعة',

      'forgotPassword': 'نسيت كلمة المرور؟',

      'dontHaveAccount': 'ليس لديك حساب؟',

      'loginEmptyFields': 'من فضلك أدخل البريد الإلكتروني وكلمة المرور',

      'signupTitle': 'إنشاء حساب',
      'signupSubtitle': 'أنشئ حسابك للمتابعة',

      'alreadyHaveAccount': 'لديك حساب بالفعل؟',

      'signupEmptyFields': 'من فضلك أكمل جميع البيانات',

      'passwordsDoNotMatch': 'كلمتا المرور غير متطابقتين',

      'accountCreatedSuccessfully': 'تم إنشاء الحساب بنجاح. سجّل الدخول الآن.',
      'authEmailAlreadyInUse': 'هذا البريد الإلكتروني مسجل بالفعل.',
      'authInvalidEmail': 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا.',
      'authWeakPassword': 'كلمة المرور ضعيفة جدًا.',
      'authUserNotFound': 'لا يوجد حساب بهذا البريد الإلكتروني.',
      'authInvalidCredential': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'authNetworkError': 'تحقق من اتصالك بالإنترنت.',
      'authTooManyRequests': 'محاولات كثيرة جدًا. حاول مرة أخرى لاحقًا.',
      'authServerError': 'حدث خطأ في الخادم. حاول مرة أخرى.',
      'authUnknownError': 'حدث خطأ. حاول مرة أخرى.',

      'latestDhikrTitle': 'فضل ذكر الله تعالى',
      'faithLectures': 'محاضرات إيمانية',

      'baqarahTafsirTitle': 'تفسير سورة البقرة',
      'quranTafsirCategory': 'تفسير القرآن الكريم',
      'ayahsOneToTen': 'الآيات 1 - 10',

      'maintainPrayerTitle': 'كيف نحافظ على الصلاة؟',
      'audioLessonsCategory': 'دروس صوتية',

      'quranTitle': 'القرآن الكريم',
      'quranSubtitle': 'اقرأ واستمع واستكشف تفسير آيات القرآن الكريم.',
      'searchSurah': 'ابحث عن سورة...',
      'noSurahsYet': 'لا توجد سور بعد',
      'quranEmptySubtitle': 'سيظهر محتوى القرآن هنا عند إضافته.',

      'recitationUnavailable': 'التلاوة غير متاحة حاليًا.',
      'unableToPlayRecitation': 'تعذر تشغيل التلاوة.',
      'tafsirWillBeAdded': 'سيتم إضافة التفسير لاحقًا.',

      'menu': 'القائمة',
      'surahInformation': 'معلومات السورة',
      'listen': 'الاستماع',
      'ayahCount': 'عدد الآيات',
      'surahNumber': 'رقم السورة',
      'revelationType': 'نوع السورة',
      'tafsirSaadi': 'تفسير السعدي',
      'tafsirIbnKathir': 'تفسير ابن كثير',
      'tafsirJalalayn': 'تفسير الجلالين',

      'settings': 'الإعدادات',
      'chooseLanguage': 'اختر لغة التطبيق',

      'appearance': 'المظهر',
      'chooseAppearance': 'اختر مظهر التطبيق',
      'systemTheme': 'النظام',
      'lightTheme': 'فاتح',
      'darkTheme': 'داكن',
      'systemThemeSubtitle': 'استخدام إعدادات الجهاز',
      'lightThemeSubtitle': 'استخدام الوضع الفاتح دائمًا',
      'darkThemeSubtitle': 'استخدام الوضع الداكن دائمًا',
      'mushafReadingMode': 'وضع قراءة المصحف',
      'chooseMushafReadingMode': 'اختر مظهر المصحف أثناء القراءة',
      'normalReadingMode': 'عادي',
      'normalReadingModeSubtitle': 'استخدام ألوان المصحف الأصلية',
      'nightReadingMode': 'ليلي',
      'nightReadingModeSubtitle': 'استخدام خلفية داكنة للقراءة',
      'bookmarkLoadError': 'حدث خطأ أثناء تحميل الصفحات المحفوظة',
      'addBookmark': 'إضافة علامة حفظ',
      'removeBookmark': 'إزالة علامة الحفظ',

      'tafsirLoadError': 'حدث خطأ أثناء تحميل التفسير',
      'noTafsir': 'لا يوجد تفسير',
      'noTafsirForSurah': 'لم يتم العثور على بيانات لهذه السورة.',
      'noTafsirForAyah': 'لا يوجد تفسير لهذه الآية.',
      'readBook': 'قراءة الكتاب',

      'aboutBook': 'عن الكتاب',
      'pages': 'صفحة',
      'bookDescriptionUnavailable': 'لا يوجد وصف متاح لهذا الكتاب حاليًا.',
      'pageCountUnavailable': 'عدد الصفحات غير متاح',
      'publisherUnavailable': 'دار النشر غير متاحة',

      'booksTitle': 'كتب الشيخ',
      'booksSubtitle': 'كتب ومؤلفات الشيخ محمد حسان',

      'searchBooks': 'ابحث عن كتاب...',
      'allBooks': 'جميع الكتب',
      'book': 'كتاب',
      'booksCount': 'كتاب',

      'featuredBook': 'كتاب مميز',

      'publisher': 'دار النشر',

      'noBooksYet': 'لا توجد كتب بعد',
      'booksEmptySubtitle': 'ستظهر الكتب هنا عند إضافتها.',

      'booksLoadError': 'تعذر تحميل الكتب',

      'allCategory': 'الكل',
      'aqeedahCategory': 'العقيدة',
      'quranTafsirCategoryBooks': 'القرآن والتفسير',
      'seerahHistoryCategory': 'السيرة والتاريخ',
      'hadithCategory': 'الحديث والسنة',
      'fiqhCategory': 'الفقه',
      'dawahCategory': 'الدعوة',
      'educationEthicsCategory': 'التربية والأخلاق',
      'akhirahCategory': 'الآخرة والرقائق',
      'knowledgeThroughBooks': 'العلم من خلال الكتب',
      'booksIntro': 'استكشف كتب ومؤلفات الشيخ محمد حسان',
      'pageCount': 'عدد الصفحات',
      'bookUnavailable': 'هذا الكتاب غير متاح للقراءة حاليًا.',
      'goToPage': 'الانتقال إلى صفحة',
      'go': 'انتقال',
      'cancel': 'إلغاء',
      'booksHeaderTitle': 'الكتب',

      'programsTitle': 'البرامج',
      'programsSubtitle': 'برامج الشيخ محمد حسان وسلاسل الحلقات',
      'continueWatching': 'Continue Watching',
      'startWatching': 'Start watching',
      'stoppedAt': 'Stopped at',
      'searchPrograms': 'البحث في البرامج',
      'episodes': 'حلقة',
      'programsLoadError': 'حدث خطأ أثناء تحميل البرامج',
      'noProgramsYet': 'لا توجد برامج حاليًا',
      'programsEmptySubtitle': 'ستظهر البرامج هنا عند إضافتها.',
      'noProgramsFound': 'لا توجد نتائج',
      'programEpisodes': 'حلقات البرنامج',
      'episode': 'الحلقة',
      'noEpisodesYet': 'لا توجد حلقات حاليًا',
      'episodesEmptySubtitle': 'ستظهر حلقات البرنامج هنا عند إضافتها.',
      'episodesLoadError': 'حدث خطأ أثناء تحميل الحلقات',
      'programsHomeSubtitle': 'برامج وسلاسل الشيخ',
      'sermonsTitle': 'الخطب',
      'sermonsSubtitle': 'خطب ومحاضرات الشيخ',

      'sermonsPageSubtitle': 'خطب ومحاضرات الشيخ في موضوعات مختلفة',
      'searchSermons': 'البحث في الخطب',
      'sermonsLoadError': 'حدث خطأ أثناء تحميل الخطب',
      'noSermonsYet': 'لا توجد خطب حاليًا',
      'sermonsEmptySubtitle': 'ستظهر الخطب هنا عند إضافتها.',
      'noSermonsFound': 'لا توجد نتائج',
      'heartSoftenersCategory': 'الرقائق',
      'repentanceCategory': 'التوبة',
      'fitanCategory': 'الفتن',
      'familySocietyCategory': 'الأسرة والمجتمع',
      'seerahCategory': 'السيرة',
      'occasionsCategory': 'المناسبات',
      'forgotPasswordTitle': 'إعادة تعيين كلمة المرور',
      'forgotPasswordSubtitle':
          'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.',
      'sendResetLink': 'إرسال رابط إعادة التعيين',
      'resetEmailSent':
          'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.',
      'resetPasswordEmptyEmail': 'من فضلك أدخل بريدك الإلكتروني.',
      'logout': 'تسجيل الخروج',
      'profileEmailUnavailable': 'البريد الإلكتروني غير متاح',
      'profileNameUnavailable': 'الاسم غير متاح',
      'profileLoadError': 'تعذر تحميل الملف الشخصي',
      'profileLoadErrorSubtitle': 'تعذر تحميل بيانات الملف الشخصي.',

      'notifications': 'الإشعارات',
      'notificationsSubtitle': 'آخر التحديثات والتذكيرات',
      'noNotifications': 'لا توجد إشعارات بعد',
      'noNotificationsSubtitle': 'ستظهر هنا التحديثات والتذكيرات الجديدة.',
      'markAllAsRead': 'تحديد الكل كمقروء',
      'clearNotifications': 'مسح الإشعارات',
      'clearNotificationsTitle': 'مسح الإشعارات؟',
      'clearNotificationsMessage': 'سيتم حذف جميع الإشعارات المحفوظة.',
      'clear': 'مسح',
      'justNow': 'الآن',
      'minutesAgo': 'دقيقة',
      'hoursAgo': 'ساعة',
      'daysAgo': 'يوم',

      'continueBookReminderTitle': 'تابع القراءة',
      'continueBookReminderBody': 'لا تنسَ متابعة كتابك من حيث توقفت.',
      'continueProgramReminderTitle': 'تابع المشاهدة',
      'continueProgramReminderBody': 'لا تنسَ متابعة الحلقة من حيث توقفت.',
      'continueQuranReminderTitle': 'تابع قراءة القرآن',
      'continueQuranReminderBody': 'لا تنسَ متابعة قراءة القرآن من حيث توقفت.',
      'fullScreen': 'ملء الشاشة',
      'mushafPageLoadError': 'تعذر تحميل صفحة المصحف',
      'mushafPageEmpty': 'لا توجد بيانات لهذه الصفحة',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
