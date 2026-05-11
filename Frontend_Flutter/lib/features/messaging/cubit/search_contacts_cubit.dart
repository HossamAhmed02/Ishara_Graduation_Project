import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../data/repositories/contacts_repository.dart';
import '../data/models/contact_model.dart';
import 'search_contacts_state.dart';

class SearchContactsCubit extends Cubit<SearchContactsState> {
  final ContactsRepository _repository = ContactsRepository();

  Set<String>? _cachedContactIds;

  int _currentPage = 1;
  static const int _pageSize = 5;
  String _lastQuery = '';

  SearchContactsCubit() : super(SearchContactsInitial());

  Future<Set<String>> _fetchExistingContactIds({
    bool forceRefresh = false,
  }) async {
    if (_cachedContactIds != null && !forceRefresh) {
      return _cachedContactIds!;
    }
    try {
      final contacts = await _repository.getMyContacts();
      _cachedContactIds = contacts.map((c) => c.id).toSet();
      return _cachedContactIds!;
    } catch (_) {
      return _cachedContactIds ?? {};
    }
  }

  Future<void> search(String query, {bool loadMore = false}) async {
    if (query.trim().isEmpty) return;

    if (!loadMore) {
      _currentPage = 1;
      _lastQuery = query;

      _cachedContactIds = null;
      emit(SearchContactsLoading());
    }

    try {
      final existingIds = await _fetchExistingContactIds(
        forceRefresh: !loadMore,
      );

      final results = await _repository.searchContacts(
        query: query,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      final currentResults = loadMore && state is SearchContactsLoaded
          ? (state as SearchContactsLoaded).results
          : <ContactModel>[];

      final allResults = [...currentResults, ...results];
      final hasMore = results.length == _pageSize;

      if (loadMore) _currentPage++;

      final previousAddedIds = state is SearchContactsLoaded
          ? (state as SearchContactsLoaded).addedIds
          : <String>{};
      final syncedIds = {...existingIds, ...previousAddedIds};

      emit(
        SearchContactsLoaded(
          results: allResults,
          hasMore: hasMore,
          addedIds: syncedIds,
          loadingIds: const {},
        ),
      );
    } on DioException catch (e) {
      emit(
        SearchContactsFailure(
          e.response?.data?['message'] ?? 'Search failed',
          previousState: state is SearchContactsLoaded
              ? state as SearchContactsLoaded
              : null,
        ),
      );
    } catch (e) {
      emit(
        SearchContactsFailure(
          'An unexpected error occurred',
          previousState: state is SearchContactsLoaded
              ? state as SearchContactsLoaded
              : null,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (_lastQuery.isEmpty) return;
    if (state is! SearchContactsLoaded) return;
    final current = state as SearchContactsLoaded;
    if (!current.hasMore) return;
    await search(_lastQuery, loadMore: true);
  }

  Future<void> addContact(String contactId) async {
    if (state is! SearchContactsLoaded) return;
    final current = state as SearchContactsLoaded;

    if (current.loadingIds.contains(contactId)) return;

    emit(current.copyWith(loadingIds: {...current.loadingIds, contactId}));

    try {
      await _repository.addContact(contactId);

      final existingIds = await _fetchExistingContactIds(forceRefresh: true);

      if (isClosed) return;

      if (state is SearchContactsLoaded) {
        final updated = state as SearchContactsLoaded;
        final newLoadingIds = Set<String>.from(updated.loadingIds)
          ..remove(contactId);

        emit(
          updated.copyWith(addedIds: existingIds, loadingIds: newLoadingIds),
        );
      }
    } on DioException catch (e) {
      if (!isClosed && state is SearchContactsLoaded) {
        final updated = state as SearchContactsLoaded;
        final newLoadingIds = Set<String>.from(updated.loadingIds)
          ..remove(contactId);
        emit(updated.copyWith(loadingIds: newLoadingIds));
      }
      emit(
        SearchContactsFailure(
          e.response?.data?['message'] ?? 'Failed to add contact',
          previousState: state is SearchContactsLoaded
              ? state as SearchContactsLoaded
              : null,
        ),
      );
    } catch (e) {
      if (!isClosed && state is SearchContactsLoaded) {
        final updated = state as SearchContactsLoaded;
        final newLoadingIds = Set<String>.from(updated.loadingIds)
          ..remove(contactId);
        emit(updated.copyWith(loadingIds: newLoadingIds));
      }
      emit(
        SearchContactsFailure(
          'An unexpected error occurred',
          previousState: state is SearchContactsLoaded
              ? state as SearchContactsLoaded
              : null,
        ),
      );
    }
  }

  Future<void> removeContactFromSearch(String contactId) async {
    if (state is! SearchContactsLoaded) return;
    final current = state as SearchContactsLoaded;

    if (current.loadingIds.contains(contactId)) return;

    emit(current.copyWith(loadingIds: {...current.loadingIds, contactId}));

    try {
      await _repository.deleteContact(contactId);

      final existingIds = await _fetchExistingContactIds(forceRefresh: true);

      if (isClosed) return;

      if (state is SearchContactsLoaded) {
        final updated = state as SearchContactsLoaded;

        final newLoadingIds = Set<String>.from(updated.loadingIds)
          ..remove(contactId);

        emit(
          updated.copyWith(addedIds: existingIds, loadingIds: newLoadingIds),
        );
      }
    } on DioException catch (e) {
      if (!isClosed && state is SearchContactsLoaded) {
        final updated = state as SearchContactsLoaded;

        final newLoadingIds = Set<String>.from(updated.loadingIds)
          ..remove(contactId);
        emit(updated.copyWith(loadingIds: newLoadingIds));
      }
      emit(
        SearchContactsFailure(
          e.response?.data?['message'] ?? 'Failed to remove contact',
          previousState: state is SearchContactsLoaded
              ? state as SearchContactsLoaded
              : null,
        ),
      );
    } catch (e) {
      if (!isClosed && state is SearchContactsLoaded) {
        final updated = state as SearchContactsLoaded;

        final newLoadingIds = Set<String>.from(updated.loadingIds)
          ..remove(contactId);
        emit(updated.copyWith(loadingIds: newLoadingIds));
      }
      emit(
        SearchContactsFailure(
          'An unexpected error occurred',
          previousState: state is SearchContactsLoaded
              ? state as SearchContactsLoaded
              : null,
        ),
      );
    }
  }
}
