import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.repository}) : super(ProfileInitial());

  final ProfileRepository repository;

  Future<void> getProfile() async {
    emit(ProfileLoading());

    try {
      final profile = await repository.getProfile();

      emit(ProfileSuccess(profile));
    } catch (_) {
      emit(ProfileError());
    }
  }
}
