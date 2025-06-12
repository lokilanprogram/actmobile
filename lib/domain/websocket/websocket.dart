import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer' as developer;
import 'package:acti_mobile/configs/constants.dart'; // Импортируем константу API

WebSocketChannel? onlineChannelSocket;

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

  AllChatWebSocketService({required this.token}) {
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
        },
        onError: (error) {
          developer.log('Ошибка все WebSocket: $error', name: 'WEBSOCKET');
        },
        cancelOnError: true,
      );
    } catch (e) {
      developer.log('Ошибка при создании WebSocket чатов: $e',
          name: 'WEBSOCKET');
      rethrow;
    }
  }

  /// Поток входящих сообщений
  Stream<String> get stream => _controller.stream;

  void sendMessage(String message) {
    try {
      _channel.sink.add(message);
      developer.log('Сообщение отправлено: $message', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при отправке сообщения: $e', name: 'WEBSOCKET');
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
      rethrow;
    }
  }

  void dispose() {
    try {
      _controller.close();
      _channel.sink.close();
      developer.log('WebSocket соединение закрыто', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при закрытии WebSocket соединения: $e',
          name: 'WEBSOCKET');
    }
  }
}
