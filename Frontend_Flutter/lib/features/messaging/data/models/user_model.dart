class ChatUser {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String lastTime;
  int unreadCount;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });

  factory ChatUser.fromContact({
    required String id,
    required String name,
    required String email,
  }) {
    return ChatUser(
      id: id,
      name: name,

      avatarUrl: '',
      lastMessage: '',
      lastTime: '',
      unreadCount: 0,
    );
  }
}
