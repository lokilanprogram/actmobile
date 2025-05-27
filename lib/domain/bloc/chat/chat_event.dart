part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}
class SendMessageEvent extends ChatEvent{
  final String chatId;
  final String message;
  final String? imagePath;
  final bool isEmptyChat;

  SendMessageEvent({required this.chatId, required this.message, required this.isEmptyChat,required 
  this.imagePath});
}

class GetAllChatsEvent extends ChatEvent{}

class DeleteChatEvent extends ChatEvent{
  final String chatId;

  DeleteChatEvent({required this.chatId});
}


class StartChatMessageEvent extends ChatEvent{
  final String userId;
  final String message;
  final String? imagePath;

  StartChatMessageEvent({required this.userId, required this.message, required this.imagePath});
}

class GetChatHistoryEvent extends ChatEvent{
  final String chatId;

  GetChatHistoryEvent({required this.chatId,});
}

