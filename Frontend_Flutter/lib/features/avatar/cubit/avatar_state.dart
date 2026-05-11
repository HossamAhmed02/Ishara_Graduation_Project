abstract class AvatarState {}

class AvatarInitial extends AvatarState {}

class AvatarLoading extends AvatarState {}

class AvatarTranslating extends AvatarState {
  final String gloss;
  AvatarTranslating(this.gloss);
}

class AvatarError extends AvatarState {
  final String message;
  AvatarError(this.message);
}
