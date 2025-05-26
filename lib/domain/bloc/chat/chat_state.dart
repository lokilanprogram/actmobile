part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

 class ChatInitial extends ChatState {}

 class GotAllChatsState extends ChatState {
  final AllChatsModel allPrivateChats;
  final AllChatsModel allGroupChats;

  GotAllChatsState({required this.allPrivateChats, required this.allGroupChats});
 }
 class GotAllChatsErrorState extends ChatState {}

 class CreatedChatState extends ChatState {
  final String chatId;
  final String accessToken;
  final ChatModel chatModel;

  CreatedChatState({required this.chatId, required this.accessToken, required this.chatModel});
 }

 class CreatedChatErrorState extends ChatState {}

 class SentMessageState extends ChatState {
  final MessageModel messageModel;

  SentMessageState({required this.messageModel});
 }

 class SentMessageErrorState extends ChatState {}
 
 class GotChatHistoryState extends ChatState {
  final ChatModel chatModel;

  GotChatHistoryState({required this.chatModel});
 }

 class GotChatHistoryErrorState extends ChatState {}

class StartedChatMessageState extends ChatState {
  final String chatId;
  final String accessToken;
  final ChatModel chatModel;

  StartedChatMessageState({required this.chatId, required this.accessToken, required this.chatModel});
}
class StartedChatMessageErrorState extends ChatState {}