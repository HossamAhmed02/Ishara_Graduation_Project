import 'package:ishara/core/network/api_client.dart';

class MessagesApiService {
  static final MessagesApiService _instance = MessagesApiService._internal();
  factory MessagesApiService() => _instance;
  MessagesApiService._internal();

  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final dio = ApiClient.getInstance();
    await dio.post(
      '/api/Messages/send',
      data: {'receiverId': receiverId, 'content': content},
    );
  }

  Future<List<Map<String, dynamic>>> getChatHistory({
    required String receiverId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final dio = ApiClient.getInstance();
    final response = await dio.get(
      '/api/Messages/chat/$receiverId',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is Map && data['items'] != null) {
      return (data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getRecentChats() async {
    final dio = ApiClient.getInstance();
    final response = await dio.get('/api/Messages/RecentChats');
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> markMessagesAsRead(String senderId) async {
    final dio = ApiClient.getInstance();
    await dio.post('/api/Messages/MarkMessageAsRead/$senderId');
  }

  Future<List<String>> getOnlineUsers() async {
    final dio = ApiClient.getInstance();
    final response = await dio.get('/api/Messages/OnlineUsers');
    final data = response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }
}
