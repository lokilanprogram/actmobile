part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class GotAllChatsState extends ChatState {
  final AllChatsModel allPrivateChats;
  final AllChatsModel allGroupChats;
  final bool hasMorePrivateChats;
  final bool hasMoreGroupChats;

  GotAllChatsState(
      {required this.allPrivateChats,
      required this.allGroupChats,
      this.hasMorePrivateChats = true,
      this.hasMoreGroupChats = true});
}

class GotAllChatsErrorState extends ChatState {}

class CreatedChatState extends ChatState {
  final String chatId;
  final String accessToken;
  final ChatMessagesModel chatModel;

  CreatedChatState(
      {required this.chatId,
      required this.accessToken,
      required this.chatModel});
}

class CreatedChatErrorState extends ChatState {}

class DeletedChatState extends ChatState {}

class DeletedChatErrorState extends ChatState {}

class DeletedMessageState extends ChatState {}

class DeletedMessageErrorState extends ChatState {}

class SentMessageState extends ChatState {
  final ChatMessagesModel? chatModel;

  SentMessageState({required this.chatModel});
}

class SentMessageErrorState extends ChatState {
  final String error;
  SentMessageErrorState(this.error);
}

class GotChatHistoryState extends ChatState {
  final ChatMessagesModel chatModel;
  final ChatInfoModel chatInfoModel;
  final bool isLoadMore;

  GotChatHistoryState({
    required this.chatModel,
    required this.chatInfoModel,
    this.isLoadMore = false,
  });
}

class GotChatHistoryErrorState extends ChatState {}

class GotChatFromPushHistoryState extends ChatState {
  final ChatMessagesModel chatModel;
  final ChatInfoModel? chatInfoModel;

  GotChatFromPushHistoryState(
      {required this.chatModel, required this.chatInfoModel});
}

class StartedChatMessageState extends ChatState {
  final String chatId;
  final String accessToken;
  final ChatMessagesModel chatModel;

  StartedChatMessageState(
      {required this.chatId,
      required this.accessToken,
      required this.chatModel});
}

class StartedChatMessageErrorState extends ChatState {}
