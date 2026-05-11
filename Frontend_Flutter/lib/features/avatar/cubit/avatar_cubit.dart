import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import 'avatar_state.dart';

class AvatarCubit extends Cubit<AvatarState> {
  AvatarCubit() : super(AvatarInitial());

  Future<void> translateText(String text) async {
    if (text.trim().isEmpty) return;

    emit(AvatarLoading());

    try {
      final gloss = await ApiService.getGloss(text);

      emit(AvatarTranslating(gloss));
    } catch (e) {
      emit(AvatarError('Error:$e'));
    }
  }
}
