part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

 class ChatInitial extends ChatState {}

 class CreatedChatState extends ChatState {
  final String chatId;
  final String accessToken;

  CreatedChatState({required this.chatId, required this.accessToken});
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

