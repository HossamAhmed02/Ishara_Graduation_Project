import 'package:signalr_netcore/signalr_client.dart';
import 'package:ishara/core/constants/api_constants.dart';
import 'package:ishara/core/services/token_service.dart';

typedef MessageReceivedCallback = void Function(Map<String, dynamic> message);
typedef UserStatusCallback = void Function(String userId, bool isOnline);
typedef RecentChatsUpdatedCallback = void Function();

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  MessageReceivedCallback? onMessageReceived;
  UserStatusCallback? onUserStatusChanged;
  RecentChatsUpdatedCallback? onRecentChatsUpdated;

  bool get isConnected => _isConnected;

  Future<void> startConnection() async {
    if (_isConnected) return;

    final hubUrl = '${ApiConstants.baseUrl}/ChatHub';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              final token = await TokenService.getToken();
              return token ?? '';
            },
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final message = Map<String, dynamic>.from(arguments[0] as Map);
        onMessageReceived?.call(message);
        onRecentChatsUpdated?.call();
      }
    });

    _hubConnection!.on('UserOnline', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final userId = arguments[0] as String;
        onUserStatusChanged?.call(userId, true);
      }
    });

    _hubConnection!.on('UserOffline', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final userId = arguments[0] as String;
        onUserStatusChanged?.call(userId, false);
      }
    });

    _hubConnection!.onclose(({error}) {
      _isConnected = false;
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _isConnected = true;
    });

    try {
      await _hubConnection!.start();
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> stopConnection() async {
    await _hubConnection?.stop();
    _isConnected = false;
  }

  void clearCallbacks() {
    onMessageReceived = null;
    onUserStatusChanged = null;
    onRecentChatsUpdated = null;
  }
}
