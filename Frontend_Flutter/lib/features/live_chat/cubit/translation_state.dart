part of 'translation_cubit.dart';

abstract class TranslationState {}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationSuccess extends TranslationState {
  final String translatedText;
  TranslationSuccess(this.translatedText);
}

class TranslationError extends TranslationState {
  final String errorCode;
  TranslationError(this.errorCode);

  String get userMessage {
    switch (errorCode) {
      case 'model_error':
        return 'Could not detect the sign.\nPlease record a new video and try again.';
      case 'timeout_error':
        return 'Request timed out.\nPlease check your connection and try again.';
      case 'network_error':
        return 'No internet connection.\nPlease check your network.';
      case 'no_result':
        return 'No sign detected in the video.\nPlease try again with a clearer gesture.';
      case 'auth_error':
        return 'Something went wrong.\nPlease try recording again.';
      default:
        return 'Something went wrong.\nPlease record a new video and try again.';
    }
  }

  bool get canRetry => true;
}
