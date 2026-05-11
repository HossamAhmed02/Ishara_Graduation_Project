import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/core/constants/api_constants.dart';
import 'package:ishara/core/network/api_client.dart';
import 'package:ishara/features/home/models/profile_models.dart';
import 'package:ishara/features/home/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final Dio _dio = ApiClient.getInstance();

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final response = await _dio.get(ApiConstants.getProfile);
      final profile = ProfileResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      emit(ProfileLoaded(profile));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?;
      emit(ProfileError(msg ?? 'Failed to load profile'));
    } catch (_) {
      emit(ProfileError('Unexpected error loading profile'));
    }
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    emit(ProfileUpdateLoading());
    try {
      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: request.toJson(),
      );
      final msg =
          response.data?['message'] as String? ??
          'Profile updated successfully';
      emit(ProfileUpdateSuccess(msg));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?;
      emit(ProfileUpdateError(msg ?? 'Failed to update profile'));
    } catch (_) {
      emit(ProfileUpdateError('Unexpected error updating profile'));
    }
  }
}
