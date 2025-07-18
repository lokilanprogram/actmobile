part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String message;
  final String? imagePath;
  final bool isEmptyChat;

  SendMessageEvent(
      {required this.chatId,
      required this.message,
      required this.isEmptyChat,
      required this.imagePath});
}

class GetAllChatsEvent extends ChatEvent {
  final bool loadMorePrivate;
  final bool loadMoreGroup;
  final String chatType;

  GetAllChatsEvent({
    this.loadMorePrivate = false,
    this.loadMoreGroup = false,
    this.chatType = 'private',
  });
}

class DeleteChatEvent extends ChatEvent {
  final String chatId;

  DeleteChatEvent({required this.chatId});
}

class DeleteMessageEvent extends ChatEvent {
  final String messageId;

  DeleteMessageEvent({required this.messageId});
}

class StartChatMessageEvent extends ChatEvent {
  final String userId;
  final String message;
  final String? imagePath;

  StartChatMessageEvent(
      {required this.userId, required this.message, required this.imagePath});
}

class GetChatHistoryEvent extends ChatEvent {
  final String chatId;
  final bool isLoadMore;

  GetChatHistoryEvent({
    this.isLoadMore = false,
    required this.chatId,
  });
}

class GetChatFromPushHistoryEvent extends ChatEvent {
  final String chatId;

  GetChatFromPushHistoryEvent({
    required this.chatId,
  });
}
