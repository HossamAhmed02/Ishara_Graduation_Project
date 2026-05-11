import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/features/messaging/data/models/user_model.dart';
import 'package:ishara/features/messaging/data/services/messages_api_service.dart';
import 'package:ishara/features/messaging/data/services/signalr_service.dart';
import 'package:ishara/core/services/token_service.dart';

// ─────────────── States ───────────────
abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatUser> users;
  final Set<String> onlineUserIds;
  final String currentUserId;

  ChatListLoaded({
    required this.users,
    this.onlineUserIds = const {},
    required this.currentUserId,
  });

  ChatListLoaded copyWith({
    List<ChatUser>? users,
    Set<String>? onlineUserIds,
    String? currentUserId,
  }) {
    return ChatListLoaded(
      users: users ?? this.users,
      onlineUserIds: onlineUserIds ?? this.onlineUserIds,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}

// ─────────────── Cubit ───────────────
class ChatListCubit extends Cubit<ChatListState> {
  final MessagesApiService _api;
  final SignalRService _signalR;

  ChatListCubit()
    : _api = MessagesApiService(),
      _signalR = SignalRService(),
      super(ChatListInitial());

  Future<void> loadRecentChats() async {
    emit(ChatListLoading());
    try {
      final currentUserId = await _getCurrentUserId();

      final rawChats = await _api.getRecentChats();

      final onlineUsers = await _api.getOnlineUsers();

      final onlineSet = Set<String>.from(onlineUsers);

      final users = rawChats.map((json) {
        return ChatUser(
          id: json['contactId']?.toString() ?? '',
          name: json['fullName'] as String? ?? '',
          avatarUrl: json['avatarUrl'] as String? ?? '',
          lastMessage: json['lastMessage'] as String? ?? '',
          lastTime: _formatTime(json['lastMessageTime'] as String?),
          unreadCount: json['unreadCount'] as int? ?? 0,
        );
      }).toList();

      emit(
        ChatListLoaded(
          users: users,
          onlineUserIds: onlineSet,
          currentUserId: currentUserId,
        ),
      );

      if (!_signalR.isConnected) {
        await _signalR.startConnection();
      }
      _subscribeToSignalR(currentUserId);
    } catch (e) {
      emit(ChatListError('Loading recent chats failed: $e'));
    }
  }

  Future<String> _getCurrentUserId() async {
    final token = await TokenService.getToken();
    if (token == null || token.isEmpty) return '';

    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';

      String payload = parts[1];

      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      final decodedBytes = base64.decode(payload);
      final decodedString = utf8.decode(decodedBytes);

      final Map<String, dynamic> claims = json.decode(decodedString);

      final userId =
          claims['sub']?.toString() ??
          claims['nameid']?.toString() ??
          claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              ?.toString() ??
          claims['userId']?.toString() ??
          claims['id']?.toString() ??
          '';

      return userId;
    } catch (e) {
      return '';
    }
  }

  void _subscribeToSignalR(String currentUserId) {
    _signalR.onRecentChatsUpdated = () {
      loadRecentChats();
    };

    _signalR.onUserStatusChanged = (userId, isOnline) {
      final current = state;
      if (current is! ChatListLoaded) return;
      final updatedOnline = Set<String>.from(current.onlineUserIds);
      if (isOnline) {
        updatedOnline.add(userId);
      } else {
        updatedOnline.remove(userId);
      }
      emit(current.copyWith(onlineUserIds: updatedOnline));
    };
  }

  void markChatAsRead(String userId) {
    final current = state;
    if (current is! ChatListLoaded) return;
    final updated = current.users.map((u) {
      if (u.id == userId) {
        return ChatUser(
          id: u.id,
          name: u.name,
          avatarUrl: u.avatarUrl,
          lastMessage: u.lastMessage,
          lastTime: u.lastTime,
          unreadCount: 0,
        );
      }
      return u;
    }).toList();
    emit(current.copyWith(users: updated));
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '';
    try {
      String formattedTime = isoTime;
      if (!formattedTime.endsWith('Z')) {
        formattedTime += 'Z';
      }

      final dt = DateTime.parse(formattedTime).toLocal();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(msgDay).inDays;

      if (diff == 0) {
        final h = dt.hour;
        final m = dt.minute.toString().padLeft(2, '0');
        final p = h >= 12 ? 'PM' : 'AM';
        final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return '$dh:$m $p';
      } else if (diff == 1) {
        return 'Yesterday';
      } else if (diff < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<void> close() {
    _signalR.onRecentChatsUpdated = null;
    _signalR.onUserStatusChanged = null;
    return super.close();
  }
}
