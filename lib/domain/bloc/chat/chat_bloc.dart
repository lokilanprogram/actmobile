import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:acti_mobile/data/models/chat_info_model.dart';
import 'package:acti_mobile/data/models/chat_model.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/chat/chat_api.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  int _privateChatOffset = 0;
  int _groupChatOffset = 0;
  final int _pageLimit = 30;

  ChatBloc() : super(ChatInitial()) {
    on<GetChatHistoryEvent>((event, emit) async {
      try {
        final chatInfo = await ChatApi().getChatInfo(event.chatId);
        if (chatInfo == null) {
          emit(GotChatHistoryErrorState());
          return;
        }

        int offset = 0;
        List<MessageModel> previousMessages = [];

        if (event.isLoadMore && state is GotChatHistoryState) {
          final currentState = state as GotChatHistoryState;
          offset = currentState.chatModel.messages.length;
          previousMessages = List.from(currentState.chatModel.messages);
        }

        final chatModel = await ChatApi().getChatHistory(
          chatId: chatInfo.id,
          offset: offset,
          limit: 50,
        );

        if (chatModel != null) {
          final combinedMessages = [
            ...chatModel.messages.reversed,
            ...previousMessages,
          ];

          final updatedChatModel = chatModel.copyWith(
            messages: combinedMessages,
            total: chatModel.total,
            offset: offset,
            limit: chatModel.limit,
          );

          emit(GotChatHistoryState(
            chatModel: updatedChatModel,
            chatInfoModel: chatInfo,
            isLoadMore: event.isLoadMore,
          ));
        } else {
          emit(GotChatHistoryErrorState());
        }
      } catch (e) {
        emit(GotChatHistoryErrorState());
      }
    });

    on<GetAllChatsEvent>((event, emit) async {
      try {
        final currentState = state;
        List<Chat> allPrivateChats = [];
        List<Chat> allGroupChats = [];

        if (event.loadMorePrivate && currentState is GotAllChatsState) {
          allPrivateChats = List.from(currentState.allPrivateChats.chats);
        }
        if (event.loadMoreGroup && currentState is GotAllChatsState) {
          allGroupChats = List.from(currentState.allGroupChats.chats);
        }
        if (!event.loadMorePrivate && !event.loadMoreGroup) {
          _privateChatOffset = 0;
          _groupChatOffset = 0;
        }

        final privateChats = await ChatApi().getAllChats('private',
            offset: _privateChatOffset, limit: _pageLimit);
        final groupChats = await ChatApi()
            .getAllChats('group', offset: _groupChatOffset, limit: _pageLimit);

        if (privateChats != null) {
          allPrivateChats.addAll(privateChats.chats);
          _privateChatOffset += privateChats.chats.length;
        }

        if (groupChats != null) {
          allGroupChats.addAll(groupChats.chats);
          _groupChatOffset += groupChats.chats.length;
        }

        emit(GotAllChatsState(
            allGroupChats: AllChatsModel(
                total: groupChats?.total ?? 0,
                offset: groupChats?.offset ?? 0,
                limit: groupChats?.limit ?? 0,
                chats: allGroupChats),
            allPrivateChats: AllChatsModel(
                total: privateChats?.total ?? 0,
                offset: privateChats?.offset ?? 0,
                limit: privateChats?.limit ?? 0,
                chats: allPrivateChats),
            hasMorePrivateChats: privateChats?.chats.length == _pageLimit,
            hasMoreGroupChats: groupChats?.chats.length == _pageLimit));
      } catch (e) {
        emit(GotAllChatsErrorState());
      }
    });

    on<StartChatMessageEvent>((event, emit) async {
      Either<String, bool>? isSent;
      try {
        final storage = SecureStorageService();
        final accessToken = await storage.getAccessToken();
        final createdChat = await ChatApi().createPrivateChat(event.userId);
        if (createdChat != null) {
          if (event.imagePath == null) {
            isSent = await ChatApi().sendMessage(createdChat.id, event.message);
          } else {
            isSent = await ChatApi().sendFileMessage(
                createdChat.id, event.message, event.imagePath!);
          }
          if (isSent != null) {
            final chatModel = await ChatApi()
                .getChatHistory(chatId: createdChat.id, offset: 0);
            isSent.fold(
                (l) => emit(StartedChatMessageErrorState()),
                (r) => emit(StartedChatMessageState(
                      chatModel: chatModel!,
                      chatId: createdChat.id,
                      accessToken: accessToken!,
                    )));
          }
        }
      } catch (e) {
        emit(StartedChatMessageErrorState());
      }
    });

    on<DeleteChatEvent>((event, emit) async {
      try {
        final sentMessageModel = await ChatApi().deleteChat(event.chatId);
        if (sentMessageModel != null) {
          emit(DeletedChatState());
        }
      } catch (e) {
        emit(DeletedChatErrorState());
      }
    });

    on<SendMessageEvent>((event, emit) async {
      ChatMessagesModel? chatModel;
      Either<String, bool>? isSent;
      try {
        if (event.imagePath == null) {
          isSent = await ChatApi().sendMessage(event.chatId, event.message);
        } else {
          isSent = await ChatApi()
              .sendFileMessage(event.chatId, event.message, event.imagePath!);
        }

        if (event.isEmptyChat) {
          chatModel =
              await ChatApi().getChatHistory(chatId: event.chatId, offset: 0);
        }
        isSent.fold((l) => emit(SentMessageErrorState(l)),
            (r) => emit(SentMessageState(chatModel: chatModel)));
      } catch (e) {
        emit(SentMessageErrorState(e.toString()));
      }
    });
  }
}
