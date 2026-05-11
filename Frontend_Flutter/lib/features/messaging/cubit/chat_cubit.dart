import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/messaging/data/models/message_model.dart';
import 'package:ishara/features/messaging/data/services/messages_api_service.dart';
import 'package:ishara/features/messaging/data/services/signalr_service.dart';

// ─────────────── States ───────────────
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isOtherUserOnline;
  final String currentUserId;

  ChatLoaded({
    required this.messages,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isOtherUserOnline = false,
    required this.currentUserId,
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isOtherUserOnline,
    String? currentUserId,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isOtherUserOnline: isOtherUserOnline ?? this.isOtherUserOnline,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// ─────────────── Cubit ───────────────
class ChatCubit extends Cubit<ChatState> {
  final MessagesApiService _api;
  final SignalRService _signalR;

  final String otherUserId;

  String _currentUserId = '';
  int _currentPage = 1;
  static const int _pageSize = 20;

  ChatCubit({required this.otherUserId})
    : _api = MessagesApiService(),
      _signalR = SignalRService(),
      super(ChatInitial());

  Future<void> loadMessages(String currentUserId) async {
    _currentUserId = currentUserId;
    _currentPage = 1;
    emit(ChatLoading());

    try {
      final rawMessages = await _api.getChatHistory(
        receiverId: otherUserId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      final messages = rawMessages
          .map(Message.fromJson)
          .toList()
          .reversed
          .toList();
      final onlineUsers = await _api.getOnlineUsers();
      final isOnline = onlineUsers.contains(otherUserId);

      await _api.markMessagesAsRead(otherUserId);

      emit(
        ChatLoaded(
          messages: messages,
          hasMore: messages.length >= _pageSize,
          isOtherUserOnline: isOnline,
          currentUserId: _currentUserId,
        ),
      );

      _subscribeToSignalR();
    } catch (e) {
      emit(ChatError('Loading messages failed: $e'));
    }
  }

  Future<void> loadMoreMessages() async {
    final current = state;
    if (current is! ChatLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      _currentPage++;
      final rawMessages = await _api.getChatHistory(
        receiverId: otherUserId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      final olderMessages = rawMessages
          .map(Message.fromJson)
          .toList()
          .reversed
          .toList();
      emit(
        current.copyWith(
          messages: [...current.messages, ...olderMessages],
          isLoadingMore: false,
          hasMore: olderMessages.length >= _pageSize,
        ),
      );
    } catch (e) {
      _currentPage--;
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final current = state;
    if (current is! ChatLoaded) return;

    final optimisticMsg = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      senderId: _currentUserId,
      timestamp: DateTime.now(),
      isRead: false,
      status: MessageStatus.sent,
    );

    emit(current.copyWith(messages: [optimisticMsg, ...current.messages]));

    try {
      await _api.sendMessage(receiverId: otherUserId, content: text.trim());
    } catch (e) {
      final updated = current.messages
          .where((m) => !m.id.startsWith('temp_'))
          .toList();
      emit(current.copyWith(messages: updated));
    }
  }

  void _subscribeToSignalR() {
    _signalR.onMessageReceived = (json) {
      final current = state;
      if (current is! ChatLoaded) return;

      final newMsg = Message.fromSignalR(json);
      final isFromOtherUser = newMsg.senderId == otherUserId;
      final isFromMe = newMsg.senderId == _currentUserId;

      if (!isFromOtherUser && !isFromMe) return;

      if (isFromOtherUser) {
        _api.markMessagesAsRead(otherUserId);
      }

      final updatedMessages = List<Message>.from(current.messages);
      if (isFromMe) {
        updatedMessages.removeWhere((m) => m.id.startsWith('temp_'));
      }
      if (!updatedMessages.any((m) => m.id == newMsg.id)) {
        updatedMessages.insert(0, newMsg);
      }

      emit(current.copyWith(messages: updatedMessages));
    };

    _signalR.onUserStatusChanged = (userId, isOnline) {
      final current = state;
      if (current is! ChatLoaded) return;
      if (userId == otherUserId) {
        emit(current.copyWith(isOtherUserOnline: isOnline));
      }
    };
  }

  @override
  Future<void> close() {
    _signalR.onMessageReceived = null;
    _signalR.onUserStatusChanged = null;
    return super.close();
  }
}
