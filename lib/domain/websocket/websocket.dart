import 'package:web_socket_channel/web_socket_channel.dart';

 WebSocketChannel? onlineChannelSocket;

connectToOnlineStatus(String accessToken){
  final uri = Uri.parse('ws://93.183.81.104/ws/v1/users/status?token=$accessToken');
  onlineChannelSocket = WebSocketChannel.connect(uri);
  onlineChannelSocket?.ready;
} 

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
    print(channel.ready);
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
