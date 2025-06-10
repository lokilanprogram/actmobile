import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer' as developer;
import 'package:acti_mobile/configs/constants.dart'; // Импортируем константу API

WebSocketChannel? onlineChannelSocket;

Future<void> connectToOnlineStatus(String accessToken) async {
  try {
    final uri = Uri.parse('$WS_API/ws/v1/users/status?token=$accessToken');
    developer.log('Подключение к WebSocket: $uri', name: 'WEBSOCKET');
    onlineChannelSocket = WebSocketChannel.connect(uri);
    await onlineChannelSocket?.ready;
    developer.log('WebSocket подключен успешно', name: 'WEBSOCKET');
  } catch (e) {
    developer.log('Ошибка при подключении к WebSocket: $e', name: 'WEBSOCKET');
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
    Map<String, String> data = {
      'type': 'typing'
    };
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
    Map<String, String> data = {
      'type': 'user_joined'
    };
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
      developer.log('WebSocket соединение закрыто', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при закрытии WebSocket соединения: $e',
          name: 'WEBSOCKET');
    }
  }
}


class AllChatWebSocketService {
  final String token;

  late WebSocketChannel channel;

  AllChatWebSocketService({
    required this.token,
  }) {
    try {
      final uri = Uri.parse('$WS_API/ws/v1/chats/activity/ws?token=$token');
      developer.log('Подключение к WebSocket чатам: $uri', name: 'WEBSOCKET');
      channel = WebSocketChannel.connect(uri);
      channel.ready.then((_) {
        developer.log('WebSocket чатов подключен успешно', name: 'WEBSOCKET');
      }).catchError((e) {
        developer.log('Ошибка при подключении к WebSocket чатов: $e',
            name: 'WEBSOCKET');
      });
    } catch (e) {
      developer.log('Ошибка при создании WebSocket чатов: $e',
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
    Map<String, String> data = {
      'type': 'typing'
    };
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
    Map<String, String> data = {
      'type': 'user_joined'
    };
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
      developer.log('WebSocket соединение закрыто', name: 'WEBSOCKET');
    } catch (e) {
      developer.log('Ошибка при закрытии WebSocket соединения: $e',
          name: 'WEBSOCKET');
    }
  }
}