import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:acti_mobile/data/models/chat_info_model.dart';
import 'package:acti_mobile/data/models/chat_model.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/chat/chat_api.dart';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<GetChatHistoryEvent>((event, emit) async {
      try {
        final chatInfoModel = await ChatApi().getChatInfo(event.chatId);
        final chatModel = await ChatApi().getChatHistory(chatInfoModel!.id);
        if (chatModel != null) {
          emit(GotChatHistoryState(
              chatModel: chatModel, chatInfoModel: chatInfoModel));
        }
      } catch (e) {
        emit(GotChatHistoryErrorState());
      }
    });
    on<GetAllChatsEvent>((event, emit) async {
      try {
        final allPrivateChats = await ChatApi().getAllChats('private');
        final allGroupChats = await ChatApi().getAllChats('group');

        if (allPrivateChats != null) {
          allPrivateChats.chats.sort((a, b) {
            final aDate = a.lastMessage?.createdAt ?? a.createdAt;
            final bDate = b.lastMessage?.createdAt ?? b.createdAt;
            return bDate.compareTo(aDate);
          });
        }

        if (allGroupChats != null) {
          allGroupChats.chats.sort((a, b) {
            final aDate = a.lastMessage?.createdAt ?? a.createdAt;
            final bDate = b.lastMessage?.createdAt ?? b.createdAt;
            return bDate.compareTo(aDate);
          });
        }

        if (allPrivateChats != null) {
          allPrivateChats.chats.sort((a, b) =>
              b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt));
        }

        if (allGroupChats != null) {
          allGroupChats.chats.sort((a, b) {
            final aMessage = a.lastMessage;
            final bMessage = b.lastMessage;

            if (aMessage != null && bMessage != null) {
              return bMessage.createdAt.compareTo(aMessage.createdAt);
            } else if (aMessage != null && bMessage == null) {
              return -1;
            } else if (aMessage == null && bMessage != null) {
              return 1;
            } else {
              return 0;
            }
          });
        }
        if (allPrivateChats != null && allGroupChats != null) {
          emit(GotAllChatsState(
              allGroupChats: allGroupChats, allPrivateChats: allPrivateChats));
        }
      } catch (e) {
        emit(GotAllChatsErrorState());
      }
    });

    on<StartChatMessageEvent>((event, emit) async {
      bool? isSent = false;
      try {
        final accessToken = await storage.read(key: accessStorageToken);
        final createdChat = await ChatApi().createPrivateChat(event.userId);
        if (createdChat != null) {
          if (event.imagePath == null) {
            isSent = await ChatApi().sendMessage(createdChat.id, event.message);
          } else {
            isSent = await ChatApi().sendFileMessage(
                createdChat.id, event.message, event.imagePath!);
          }
          if (isSent != null) {
            final chatModel = await ChatApi().getChatHistory(createdChat.id);
            emit(StartedChatMessageState(
                chatModel: chatModel!,
                chatId: createdChat.id,
                accessToken: accessToken!));
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
      bool? isSent = false;
      try {
        if (event.imagePath == null) {
          isSent = await ChatApi().sendMessage(event.chatId, event.message);
        } else {
          isSent = await ChatApi()
              .sendFileMessage(event.chatId, event.message, event.imagePath!);
        }

        if (isSent != null && isSent == true) {
          if (event.isEmptyChat) {
            chatModel = await ChatApi().getChatHistory(event.chatId);
          }
          emit(SentMessageState(
            chatModel: chatModel,
          ));
        }
      } catch (e) {
        emit(SentMessageErrorState());
      }
    });
  }
}
