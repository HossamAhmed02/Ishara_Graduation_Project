import 'package:equatable/equatable.dart';
import '../data/models/contact_model.dart';

abstract class ContactsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<ContactModel> contacts;

  ContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ContactsFailure extends ContactsState {
  final String message;

  final List<ContactModel>? previousContacts;

  ContactsFailure(this.message, {this.previousContacts});

  @override
  List<Object?> get props => [message, previousContacts];
}
