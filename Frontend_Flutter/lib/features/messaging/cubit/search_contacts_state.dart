import 'package:equatable/equatable.dart';
import '../data/models/contact_model.dart';

abstract class SearchContactsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchContactsInitial extends SearchContactsState {}

class SearchContactsLoading extends SearchContactsState {}

class SearchContactsLoaded extends SearchContactsState {
  final List<ContactModel> results;
  final bool hasMore;

  final Set<String> addedIds;

  final Set<String> loadingIds;

  SearchContactsLoaded({
    required this.results,
    required this.hasMore,
    required this.addedIds,
    this.loadingIds = const {},
  });

  SearchContactsLoaded copyWith({
    List<ContactModel>? results,
    bool? hasMore,
    Set<String>? addedIds,
    Set<String>? loadingIds,
  }) {
    return SearchContactsLoaded(
      results: results ?? this.results,
      hasMore: hasMore ?? this.hasMore,
      addedIds: addedIds ?? this.addedIds,
      loadingIds: loadingIds ?? this.loadingIds,
    );
  }

  @override
  List<Object?> get props => [results, hasMore, addedIds, loadingIds];
}

class SearchContactsFailure extends SearchContactsState {
  final String message;

  final SearchContactsLoaded? previousState;

  SearchContactsFailure(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
