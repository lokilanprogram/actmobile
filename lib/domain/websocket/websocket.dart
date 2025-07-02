import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer' as developer;
import 'package:acti_mobile/configs/constants.dart'; // Импортируем константу API

WebSocketChannel? onlineChannelSocket;
AllChatWebSocketService? globalAllChatWebSocketService;
List<ChatWebSocketService> globalChatWebSocketServices = [];

Future<void> connectToOnlineStatus(String accessToken) async {
  try {
    assert(WS_API.startsWith('ws://') || WS_API.startsWith('wss://'),
        'WS_API must be a valid WebSocket URI');

    final uri = Uri.parse('$WS_API/ws/v1/users/status?token=$accessToken');
    developer.log('Подключение к WebSocket: $uri', name: 'WEBSOCKET');

    final socket = WebSocketChannel.connect(uri);
    onlineChannelSocket = socket;

    await socket.ready;
    developer.log('WebSocket подключен успешно', name: 'WEBSOCKET');
  } catch (e, stackTrace) {
    developer.log('Ошибка при подключении к WebSocket: $e',
        name: 'WEBSOCKET', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Закрывает все активные WebSocket соединения
void closeAllWebSocketConnections() {
  try {
    // Закрываем соединение статуса онлайн
    if (onlineChannelSocket != null) {
      onlineChannelSocket!.sink.close();
      onlineChannelSocket = null;
      developer.log('Закрыто соединение статуса онлайн', name: 'WEBSOCKET');
    }
    
    // Закрываем глобальный сервис всех чатов
    if (globalAllChatWebSocketService != null) {
      globalAllChatWebSocketService!.dispose();
      globalAllChatWebSocketService = null;
      developer.log('Закрыт глобальный сервис всех чатов', name: 'WEBSOCKET');
    }
    
    // Закрываем все индивидуальные чаты
    for (var chatService in globalChatWebSocketServices) {
      try {
        chatService.dispose();
      } catch (e) {
        developer.log('Ошибка при закрытии чата: $e', name: 'WEBSOCKET');
      }
    }
    globalChatWebSocketServices.clear();
    developer.log('Закрыты все индивидуальные чаты', name: 'WEBSOCKET');
    
  } catch (e) {
    developer.log('Ошибка при закрытии WebSocket соединений: $e', name: 'WEBSOCKET');
  }
}

class ChatWebSocketService {
  final String chatId;
  final String token;

  late WebSocketChannel channel;

  ChatWebSocketService({
    required this.chatId,
    required this.token,
  }) {
    try {
      final uri = Uri.parse('$WS_API/ws/v1/chats/$chatId/ws?token=$token');
      developer.log('Подключение к WebSocket чата: $uri', name: 'WEBSOCKET');
      channel = WebSocketChannel.connect(uri);
      channel.ready.then((_) {
        developer.log('WebSocket чата подключен успешно', name: 'WEBSOCKET');
      }).catchError((e) {
        developer.log('Ошибка при подключении к WebSocket чата: $e',
            name: 'WEBSOCKET');
      });
      
      // Добавляем в глобальный список для отслеживания
      globalChatWebSocketServices.add(this);
    } catch (e) {
      developer.log('Ошибка при создании WebSocket чата: $e',
          name: 'WEBSOCKET');
      rethrow;
    }
  }

  /// Отправка сообщения
  void sendMessage(String message) {
    try {
      channel.sink.add(message);
      developer.log('Сообщение отправлено: $message', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при отправке сообщения: $e', name: 'WEBSOCKET');
      rethrow;
    }
  }

  /// Печатаю
  void sendTyping() {
    Map<String, String> data = {'type': 'typing'};
    try {
      channel.sink.add(jsonEncode(data));
      developer.log('печатаю');
    } catch (e) {
      developer.log('Ошибка печатаю');
      rethrow;
    }
  }

  /// Онлайн
  void sendOnline() {
    Map<String, String> data = {'type': 'user_joined'};
    try {
      channel.sink.add(jsonEncode(data));
      developer.log('печатаю');
    } catch (e) {
      developer.log('Ошибка печатаю');
      rethrow;
    }
  }

  /// Поток входящих сообщений
  Stream get stream => channel.stream;

  /// Закрытие соединения
  void dispose() {
    try {
      channel.sink.close();
      globalChatWebSocketServices.remove(this);
      developer.log('WebSocket один соединение закрыто', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при закрытии один WebSocket соединения: $e',
          name: 'WEBSOCKET');
    }
  }
}

class AllChatWebSocketService {
  final String token;
  late WebSocketChannel _channel;
  final _controller = StreamController<String>.broadcast();
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  static AllChatWebSocketService? _instance;
  static String? _lastToken;

  factory AllChatWebSocketService({required String token}) {
    // Если уже есть экземпляр и он не был dispose, возвращаем его
    if (_instance != null && !_instance!._isDisposed && _lastToken == token) {
      return _instance!;
    }
    // Если был dispose или другой токен — создаём новый
    _instance = AllChatWebSocketService._internal(token);
    _lastToken = token;
    return _instance!;
  }

  AllChatWebSocketService._internal(this.token) {
    _connect();
  }

  void _connect() {
    try {
      final uri = Uri.parse('$WS_API/ws/v1/chats/activity/ws?token=$token');
      developer.log('Подключение к WebSocket чатам: $uri', name: 'WEBSOCKET');

      _channel = WebSocketChannel.connect(uri);

      _channel.stream.listen(
        (data) {
          _controller.add(data);
        },
        onDone: () {
          developer.log('WebSocket все закрыт', name: 'WEBSOCKET');
          _handleReconnectOrDispose();
        },
        onError: (error) {
          developer.log('Ошибка все WebSocket: $error', name: 'WEBSOCKET');
          _handleReconnectOrDispose();
        },
        cancelOnError: true,
      );
    } catch (e) {
      developer.log('Ошибка при создании WebSocket чатов: $e',
          name: 'WEBSOCKET');
      _handleReconnectOrDispose();
    }
  }

  void _handleReconnectOrDispose() {
    if (_isDisposed) return;
    // Сбросить синглтон, чтобы следующий вызов создал новый экземпляр
    _instance = null;
    _lastToken = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isDisposed && token.isNotEmpty) {
        developer.log('Попытка переподключения (создание нового синглтона)...', name: 'WEBSOCKET');
        // Переподключаемся автоматически
        _instance = AllChatWebSocketService._internal(token);
        _lastToken = token;
      }
    });
  }

  /// Поток входящих сообщений
  Stream<String> get stream => _controller.stream;

  void sendMessage(String message) {
    try {
      _channel.sink.add(message);
      developer.log('Сообщение отправлено: $message', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при отправке сообщения: $e', name: 'WEBSOCKET');
      _handleReconnectOrDispose();
      rethrow;
    }
  }

  void sendTyping() {
    final data = {'type': 'typing'};
    try {
      _channel.sink.add(jsonEncode(data));
      developer.log('печатаю');
    } catch (e) {
      developer.log('Ошибка печатаю');
      _handleReconnectOrDispose();
      rethrow;
    }
  }

  void sendOnline() {
    final data = {'type': 'user_joined'};
    try {
      _channel.sink.add(jsonEncode(data));
      developer.log('онлайн');
    } catch (e) {
      developer.log('Ошибка онлайн');
      _handleReconnectOrDispose();
      rethrow;
    }
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    try {
      _controller.close();
      _channel.sink.close();
      developer.log('WebSocket соединение закрыто', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при закрытии WebSocket соединения: $e',
          name: 'WEBSOCKET');
    }
    // Сбросить синглтон
    _instance = null;
    _lastToken = null;
  }
}
