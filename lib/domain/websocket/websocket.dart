import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocketService {
  final String chatId;
  final String token;

  late WebSocketChannel channel;

  ChatWebSocketService({
    required this.chatId,
    required this.token,
  }) {
    final uri = Uri.parse('ws://93.183.81.104/ws/v1/chats/$chatId/ws?token=${(token)}');
    channel = WebSocketChannel.connect(uri);
    channel.ready;
  }

  /// Отправка сообщения
  void sendMessage(String message) {
    channel.sink.add(message);
  }

  /// Поток входящих сообщений
  Stream get stream => channel.stream;

  /// Закрытие соединения
  void dispose() {
    channel.sink.close();
  }
}
