import 'package:equatable/equatable.dart';

abstract class VerifyResetOtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyResetOtpInitial extends VerifyResetOtpState {}

class VerifyResetOtpLoading extends VerifyResetOtpState {}

class VerifyResetOtpSuccess extends VerifyResetOtpState {
  final String email;
  final String resetToken;

  VerifyResetOtpSuccess({required this.email, required this.resetToken});

  @override
  List<Object?> get props => [email, resetToken];
}

class VerifyResetOtpFailure extends VerifyResetOtpState {
  final String message;
  VerifyResetOtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}
