part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class CreatePrivateChatEvent extends ChatEvent{
  final String userId;

  CreatePrivateChatEvent({required this.userId});
}

class SendMessageEvent extends ChatEvent{
  final String chatId;
  final String userId;
  final String message;

  SendMessageEvent({required this.chatId, required this.message, required this.userId});
}

class GetAllChatsEvent extends ChatEvent{}


class StartChatMessageEvent extends ChatEvent{
  final String userId;
  final String message;

  StartChatMessageEvent({required this.userId, required this.message});
}

class GetChatHistoryEvent extends ChatEvent{
  final String chatId;

  GetChatHistoryEvent({required this.chatId,});
}

