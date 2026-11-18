import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/signup_user.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/books/data/datasources/books_local_data_source.dart';
import '../../features/books/data/datasources/books_remote_data_source.dart';
import '../../features/books/data/repositories/books_repository_impl.dart';
import '../../features/books/data/storage/books_storage_service.dart';
import '../../features/books/domain/repositories/books_repository.dart';
import '../../features/books/presentation/cubit/books_cubit.dart';

import '../../features/programs/data/datasources/programs_local_data_source.dart';
import '../../features/programs/data/repositories/programs_repository_impl.dart';
import '../../features/programs/domain/repositories/programs_repository.dart';
import '../../features/programs/presentation/cubit/program_episodes_cubit.dart';
import '../../features/programs/presentation/cubit/programs_cubit.dart';

import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/data/settings/mushaf_settings_local_data_source.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../features/quran/presentation/cubit/mushaf_theme_cubit.dart';
import '../../features/quran/presentation/cubit/quran_cubit.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/sermons/data/datasources/sermons_local_data_source.dart';
import '../../features/sermons/data/repositories/sermons_repository_impl.dart';
import '../../features/sermons/domain/repositories/sermons_repository.dart';
import '../../features/sermons/presentation/cubit/sermons_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl<AuthRepository>()));

  sl.registerLazySingleton<SignupUser>(() => SignupUser(sl<AuthRepository>()));

  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl<AuthRepository>()));

  sl.registerLazySingleton<ResetPassword>(
    () => ResetPassword(sl<AuthRepository>()),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUser: sl<LoginUser>(),
      signupUser: sl<SignupUser>(),
      logoutUser: sl<LogoutUser>(),
      resetPassword: sl<ResetPassword>(),
    ),
  );

  sl.registerLazySingleton<BooksLocalDataSource>(
    () => BooksLocalDataSource.instance,
  );

  sl.registerLazySingleton<BooksRemoteDataSource>(
    () => BooksRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<BooksStorageService>(
    () => BooksStorageService(sl<FirebaseStorage>()),
  );

  sl.registerLazySingleton<BooksRepository>(
    () => BooksRepositoryImpl(
      localDataSource: sl<BooksLocalDataSource>(),
      remoteDataSource: sl<BooksRemoteDataSource>(),
      useLocalData: true,
    ),
  );

  sl.registerFactory<BooksCubit>(() => BooksCubit(sl<BooksRepository>()));

  sl.registerLazySingleton<ProgramsLocalDataSource>(
    () => ProgramsLocalDataSource.instance,
  );

  sl.registerLazySingleton<ProgramsRepository>(
    () =>
        ProgramsRepositoryImpl(localDataSource: sl<ProgramsLocalDataSource>()),
  );

  sl.registerFactory<ProgramsCubit>(
    () => ProgramsCubit(repository: sl<ProgramsRepository>()),
  );

  sl.registerFactory<ProgramEpisodesCubit>(
    () => ProgramEpisodesCubit(repository: sl<ProgramsRepository>()),
  );

  sl.registerLazySingleton<QuranRepository>(() => const QuranRepositoryImpl());

  sl.registerFactory<QuranCubit>(() => QuranCubit(sl<QuranRepository>()));

  sl.registerLazySingleton<MushafSettingsLocalDataSource>(
    () => MushafSettingsLocalDataSource.instance,
  );

  sl.registerFactory<MushafThemeCubit>(
    () =>
        MushafThemeCubit(localDataSource: sl<MushafSettingsLocalDataSource>()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(repository: sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<SermonsLocalDataSource>(
    () => SermonsLocalDataSource.instance,
  );

  sl.registerLazySingleton<SermonsRepository>(
    () => SermonsRepositoryImpl(
      localDataSource: sl<SermonsLocalDataSource>(),
    ),
  );

  sl.registerFactory<SermonsCubit>(
    () => SermonsCubit(repository: sl<SermonsRepository>()),
  );
}
