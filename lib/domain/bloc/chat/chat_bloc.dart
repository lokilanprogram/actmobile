import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/chat_model.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/domain/api/chat/chat_api.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
     on<GetChatHistoryEvent>((event, emit) async{
      try{
        final chatModel = await ChatApi().getChatHistory(event.chatId);
        if(chatModel!=null){
          emit(GotChatHistoryState(chatModel: chatModel ));
        }
      }catch(e){
        emit(GotChatHistoryErrorState());
      }
    });

    on<CreatePrivateChatEvent>((event, emit) async{
      try{
        final accessToken = await storage.read(key: accessStorageToken);
        final createdChatModel = await ChatApi().createPrivateChat(event.userId);
        if(createdChatModel!=null){
          emit(CreatedChatState(chatId: createdChatModel.id,accessToken:accessToken! ));
        }
      }catch(e){
        emit(CreatedChatErrorState());
      }
    });

      on<SendMessageEvent>((event, emit) async{
      try{
        if(event.chatId == null){
         final createdChat =  await ChatApi().createPrivateChat(event.userId);
         if(createdChat!=null){
          final sentMessageModel = await ChatApi().sendMessage(createdChat.id, event.message);
        if(sentMessageModel!=null){
          emit(SentMessageState(messageModel: sentMessageModel));
        }
         }
        }else{
        final sentMessageModel = await ChatApi().sendMessage(event.chatId!, event.message);
        if(sentMessageModel!=null){
          emit(SentMessageState(messageModel: sentMessageModel));
        }
        }
      }catch(e){
        emit(SentMessageErrorState());
      }
    });
  }
}
