enum MessageStatus { sent, delivered, seen }

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.isRead,
    this.status = MessageStatus.sent,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    MessageStatus status = MessageStatus.sent;
    if (json['isRead'] == true) {
      status = MessageStatus.seen;
    } else if (json['isDelivered'] == true) {
      status = MessageStatus.delivered;
    }

    final rawSentAt = json['sentAt'] as String?;
    DateTime timestamp;

    if (rawSentAt != null) {
      String formattedTime = rawSentAt;
      if (!formattedTime.endsWith('Z')) {
        formattedTime += 'Z';
      }
      timestamp = DateTime.parse(formattedTime).toLocal();
    } else {
      timestamp = DateTime.now();
    }

    return Message(
      id: json['id']?.toString() ?? '',
      text: json['content'] as String? ?? '',
      senderId: json['senderId']?.toString() ?? '',
      timestamp: timestamp,
      isRead: json['isRead'] as bool? ?? false,
      status: status,
    );
  }

  factory Message.fromSignalR(Map<String, dynamic> json) {
    final rawSentAt = json['sentAt'] as String?;
    DateTime timestamp;

    if (rawSentAt != null) {
      String formattedTime = rawSentAt;
      if (!formattedTime.endsWith('Z')) {
        formattedTime += 'Z';
      }
      timestamp = DateTime.parse(formattedTime).toLocal();
    } else {
      timestamp = DateTime.now();
    }

    return Message(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['content'] as String? ?? '',
      senderId: json['senderId']?.toString() ?? '',
      timestamp: timestamp,
      isRead: false,
      status: MessageStatus.sent,
    );
  }

  Message copyWith({MessageStatus? status, bool? isRead}) {
    return Message(
      id: id,
      text: text,
      senderId: senderId,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
    );
  }
}
