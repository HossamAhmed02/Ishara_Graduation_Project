import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../data/repositories/contacts_repository.dart';
import 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _repository = ContactsRepository();

  ContactsCubit() : super(ContactsInitial());

  Future<void> getMyContacts() async {
    emit(ContactsLoading());
    try {
      final contacts = await _repository.getMyContacts();
      emit(ContactsLoaded(contacts));
    } on DioException catch (e) {
      emit(
        ContactsFailure(
          e.response?.data?['message'] ?? 'Failed to load contacts',
        ),
      );
    } catch (e) {
      emit(ContactsFailure('An unexpected error occurred'));
    }
  }

  Future<void> deleteContact(String contactId) async {
    final previousContacts = state is ContactsLoaded
        ? (state as ContactsLoaded).contacts
        : null;

    if (previousContacts != null) {
      final updated = previousContacts.where((c) => c.id != contactId).toList();
      emit(ContactsLoaded(updated));
    }

    try {
      await _repository.deleteContact(contactId);

      await getMyContacts();
    } on DioException catch (e) {
      if (previousContacts != null) {
        emit(ContactsLoaded(previousContacts));
      }
      emit(
        ContactsFailure(
          e.response?.data?['message'] ?? 'Failed to remove contact',
          previousContacts: previousContacts,
        ),
      );
    } catch (e) {
      if (previousContacts != null) {
        emit(ContactsLoaded(previousContacts));
      }
      emit(
        ContactsFailure(
          'An unexpected error occurred',
          previousContacts: previousContacts,
        ),
      );
    }
  }
}
