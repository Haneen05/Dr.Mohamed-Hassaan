import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remoteDataSource);

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<ProfileEntity> getProfile() async {
    final profile = await remoteDataSource.getProfile();

    return ProfileEntity(
      id: profile.id,
      name: profile.name,
      email: profile.email,
    );
  }
}
