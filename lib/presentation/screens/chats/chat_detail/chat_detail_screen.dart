import 'dart:convert';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/data/models/public_user_model.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final PublicUserModel? publicUserModel;
  final String? userId;
  const ChatDetailScreen({super.key,required this.publicUserModel,required this.userId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChatWebSocketService? webSocketService;
  final textController = TextEditingController();
   ScrollController scrollController = ScrollController();

  bool isMe = false;
  bool isLoading = false;

  String? chatId;
  String? userId;

  List<MessageModel> messages = [];
  String? interlocutorName;
  String? interlocutorAvatar;

  @override
  void initState() {
      setState(() {
      isLoading = true;
    });
    initialize();
    super.initState();
  }

  initialize()async{
    context.read<ChatBloc>().add(CreatePrivateChatEvent(userId: widget.userId!));
    final profileUserId = await storage.read(key: userIdStorage);
    setState(() {
    userId = profileUserId;
      interlocutorName = widget.publicUserModel?.name;
      interlocutorAvatar = widget.publicUserModel?.photoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToEnd());

    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state)  {
        if(state is StartedChatMessageState){
          setState(() {
            webSocketService = ChatWebSocketService(
      chatId: state.chatId,
      token: state.accessToken,
    );
            messages = state.chatModel.messages; 
            chatId = state.chatId;
          });
        }
        if(state is GotChatHistoryState){
          setState(() {
            messages = state.chatModel.messages;
            isLoading = false;
          });
        }
        if(state is GotChatHistoryErrorState){
          setState(() {
            isLoading = false;
          });
        }
        if(state is CreatedChatState){
          setState(() {
            webSocketService = ChatWebSocketService(
      chatId: state.chatId,
      token: state.accessToken,
    );
          messages = state.chatModel.messages;
          isLoading = false;
          });
          chatId = state.chatId;
         }
         if(state is CreatedChatErrorState){
          setState(() {
            isLoading = false;
          });
         }
      },
      child: Scaffold(
            bottomNavigationBar: Material(
              elevation:1.2,
              child: Container(decoration: BoxDecoration(
                                      color: Colors.white
                                    ),width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 15, top: 30,bottom: 50),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: TextFormField(
                                              controller: textController,
                                        decoration: InputDecoration(
                                          hintText: 'Сообщение',
                                          filled: true,
                                          fillColor: Color(0xFFF2F2F2),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                            borderSide: BorderSide.none,
                                          ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: SvgPicture.asset('assets/icons/icon_pin_files.svg'),
                                                onPressed: () {
                                                },
                                              ),
                                              IconButton(
                                                icon: SvgPicture.asset('assets/icons/icon_send_message.svg'),
                                                onPressed: () {
                                                  context.read<ChatBloc>().add(SendMessageEvent(chatId: chatId!, message: textController.text, userId: widget.userId!));
                                                  setState(() {
                                                    textController.clear();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      
                                          ),
                                        ),
                                      ),
                                    ),
            ),
              resizeToAvoidBottomInset: true,
                backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                titleSpacing: 1.3,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.more_vert,
                                    )),
                  ),
                ],
                title:Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [interlocutorAvatar == null
                                    ? CircleAvatar(
                                        maxRadius: 26,
                                        backgroundImage: AssetImage(
                                          'assets/images/image_profile.png',
                                        ))
                                    : CircleAvatar(
                                        maxRadius: 26,
                                        backgroundImage:
                                            NetworkImage(interlocutorAvatar!)),
                          SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                            interlocutorName ?? '...',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 17.14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                Text('Oнлайн',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13,),
                                          ),
                          ],
                        ),
                        
                                      
                      ],
                    ),
                  ),
                ),
              ),
              body:isLoading
          ? LoaderWidget()
          :  SafeArea(
                child: Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Column(
                          children: [
                            messages.isEmpty
                                ? Expanded(
                                    child: ListView(
                                      children: [
                                      ],
                                    ),
                                  )
                                :     Expanded(
            child: StreamBuilder(
              stream: webSocketService?.stream,
              builder: (context, snapshot) {
                   if (snapshot.hasData) {
      final result = ChatSnapshotModel.fromJson(jsonDecode(snapshot.data));
      final newMessage = result.message;
      
      final alreadyExists = messages.any((m) => m.id == newMessage.id);
      if (!alreadyExists) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            messages.add(newMessage);
          });
        });
      }
    }
                return  ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    itemBuilder: (context, index) {
                                      isMe = messages[index].userId == userId;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Card(
                                              elevation: 1.4,
                                                color: isMe
                                                      ? mainBlueColor
                                                      : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(20),
                                                    topRight: Radius.circular(20),
                                                    bottomLeft: Radius.circular(
                                                        isMe ? 20 : 0),
                                                    bottomRight: Radius.circular(
                                                        isMe ? 0 : 20),
                                                  ),
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                padding: EdgeInsets.all(15),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(isMe?'Вы': messages[index].user.name,style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          color:isMe? Colors.white:mainBlueColor,
                                                          fontWeight: FontWeight.bold
                                                        ),),
                                                        SizedBox(width: 45,),
                                                           Text(DateFormat('HH:mm').format(messages[index].createdAt,
                                                        ),style: TextStyle(fontFamily: 'Gilroy',color:isMe? Colors.white:Colors.black,fontSize: 16),),
                                                       isMe? SvgPicture.asset('assets/icons/icon_readed.svg'):Container()
                                                      ],
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      messages[index].content,
                                                      style: TextStyle(
                                                        height: 1.3,
                                                          fontSize: 16,
                                                          fontFamily: 'Jakarta',
                                                          color: isMe
                                                              ? Colors.white
                                                              : Colors.black),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    controller: scrollController,
                                    itemCount: messages.length,
                                  );
              },
            ),
          ),
                         
                          ],
                        ),
                      ),
              )),
    );
  }

  void scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1), curve: Curves.easeOut);
    }
  }
}
