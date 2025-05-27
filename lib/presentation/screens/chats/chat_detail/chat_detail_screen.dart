import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String interlocutorName;
  final String? trailingText;
  final String? interlocutorAvatar;
  final String? interlocutorChatId;
  final String? interlocutorUserId;
  const ChatDetailScreen({super.key,required this.interlocutorAvatar,required this.interlocutorName, required this.interlocutorChatId,required this.interlocutorUserId,
  required this.trailingText});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChatWebSocketService? webSocketService;
  final messageController = TextEditingController();
  final seacrhController = TextEditingController();
   ScrollController scrollController = ScrollController();
  

  final picker = ImagePicker();
  bool isSearched = false;
  bool isMe = false;
  bool isLoading = false;

  String? chatId;
  String? profileUserId;

  List<MessageModel> messages = [];
  String? interlocutorName;
  String? interlocutorAvatar;

   XFile? file;
   bool isUpdatedPhoto = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize()async{
    setState(() {
      isLoading = true;
    });
    final userId = await storage.read(key: userIdStorage);
    final accessToken = await storage.read(key: accessStorageToken);
    if(widget.interlocutorChatId!=null){
      webSocketService = ChatWebSocketService(
      chatId: widget.interlocutorChatId!,
      token: accessToken!,
    );
    
    context.read<ChatBloc>().add(GetChatHistoryEvent(chatId: widget.interlocutorChatId!));
    }
    setState(() {
      profileUserId = userId;
      chatId = widget.interlocutorChatId;
      interlocutorName = widget.interlocutorName;
      interlocutorAvatar = widget.interlocutorAvatar;
      isLoading = false;
    });
  }

  @override
  dispose(){
    webSocketService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToEnd());

    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state)  {
        if(state is SentMessageState){
          if(state.chatModel != null){
            setState(() {
              messages = state.chatModel!.messages;
            });
          }
        }
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

          if(state is DeletedChatState){
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, true);
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
        if(state is GotChatHistoryErrorState){
          setState(() {
            isLoading = false;
          });
        }

        if(state is DeletedChatErrorState){
           setState(() {
            isLoading = false;
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
                backgroundColor: Colors.white,
              appBar:isSearched?AppBar(backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: IconButton(onPressed: (){
                    Navigator.pop(context,false);
                  }, icon: Icon(Icons.arrow_back_ios)),
                ),
                title:  Padding(
                                            padding: const EdgeInsets.only(right: 20),
                                            child: TextFormField(
                                              controller: messageController,
                                        decoration: InputDecoration(
                                          hintText: 'Поиск',
                                        isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,color: Colors.blue
                                            ),
                                          ),
                                           focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,color: Colors.blue
                                            ),
                                          ),
                                        ),
                                      )
                                      
                                          ),
              ): AppBar(
                backgroundColor: Colors.white,
                titleSpacing: 1.3,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: IconButton(onPressed: (){
                    Navigator.pop(context,false);
                  }, icon: Icon(Icons.arrow_back_ios)),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: PopupMenuButton<int>(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          offset: const Offset(0, 20),
          itemBuilder: (BuildContext context) => [
             PopupMenuItem<int>(
                value: 0,
                onTap: (){
                  setState(() {
                    isSearched = true;
                  });
                },
                child: Row(
                  children:  [
                    SvgPicture.asset('assets/icons/icon_search.svg'),
                    SizedBox(width: 10),
                    Text("Поиск",style: TextStyle(
                      fontFamily: 'Gilroy',fontSize: 12.93,
                      color: Colors.black
                    ),),
                  ],
                ),
              ),
               PopupMenuItem<int>(
                value: 0,
                onTap: (){
                  if(chatId!=null){
                    showBlockDialog(context, 'Удалить диалог?',
                    widget.trailingText!=null? 'Вы точно хотите удалить групповой чат?': 'Вы точно хотите удалить диалог c пользователем $interlocutorName?', (){
                      setState(() {
                        isLoading = true;
                      });
                      context.read<ChatBloc>().add(DeleteChatEvent(chatId: chatId!));
                    });
                  }
                },
                child: Row(
                  children:  [
                    SvgPicture.asset('assets/icons/icon_delete.svg'),
                    SizedBox(width: 10),
                    Text("Удалить у всех",style: TextStyle(
                      fontFamily: 'Gilroy',fontSize: 12.93,
                      color: Colors.red
                    ),),
                  ],
                ),
              ),
          ],
          child: const Icon(Icons.more_vert, color: Colors.black),
        ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                              interlocutorName ?? '...',
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 17.14,
                                                  overflow: TextOverflow.visible,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                SizedBox(
                                  height:widget.trailingText!=null? 5:0,
                                ),
                                widget.trailingText !=null?
                                Text(widget.trailingText!,
                                              style: TextStyle(
                                                  fontFamily: 'Gilroy',
                                                  fontSize: 16,),
                                            )
                                :  Text('Онлайн',
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 13,),
                                            ),
                            ],
                          ),
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
              stream: webSocketService!.stream,
              builder: (context, snapshot) {
                   if (snapshot.hasData) {
      final result = ChatSnapshotModel.fromJson(jsonDecode(snapshot.data));
                    if(result.type =='user_typing'){
                      print(result.type);
                    }
      final newMessage = result.message;
      final alreadyExists = messages.any((m) => m.id == newMessage.id);
      if (!alreadyExists) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            messages.add(newMessage);
          });
        });
      }
    }return ListView.builder(
  shrinkWrap: true,
  primary: false,
  itemCount: messages.length,
  controller: scrollController,
  itemBuilder: (context, index) {
    final message = messages[index];
    final isMe = message.userId == profileUserId;
    final hasAttachment = message.attachmentUrl != null;
    final isLongText = message.content.length > 40;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
             constraints: BoxConstraints(
    maxWidth: (hasAttachment || isLongText)
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width * 0.45,
  ),
              child: Card(
                elevation: 1.4,
                color: isMe ? mainBlueColor : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 20),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Верхняя строка: имя и время
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              isMe ? 'Вы' : message.user.name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: isMe ? Colors.white : mainBlueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(message.createdAt),
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 5,),
                                isMe
                                    ? SvgPicture.asset(
                                        'assets/icons/icon_readed.svg',
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (hasAttachment) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.attachmentUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 300,
                          ),
                        ),
                      ],

                      if (message.content.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          message.content,
                          style: TextStyle(
                            height: 1.3,
                            fontSize: 16,
                            fontFamily: 'Jakarta',
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
);

              },
            ),
          ),
            inputMessage(context),
                         
                          ],
                        ),
                      ),
              )),
    );
  }

  Widget inputMessage(BuildContext context) {
    return 
        Container(decoration: BoxDecoration(
                                        color: Colors.white
                                      ),width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 15, left: 15, top: 30,bottom: 50),
                                          child: 
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(15)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: Padding(
                                                    padding:  EdgeInsets.all(isUpdatedPhoto ? 8.0:0),
                                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                    
                                                            isUpdatedPhoto ? Stack(
                                                              children: [
                                                                Positioned(
                                                                  child: Image.file(File(file!.path),fit: BoxFit.cover,
                                                                  height: 85,width: 85,),
                                                                ),
                                                                Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  file = null;
                  isUpdatedPhoto = false;
                });
              },
              child: Container(width: 20,
              height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
          ),
                                                              ],
                                                            ):Container(),
                                                        TextFormField(
                                                          controller: messageController,
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
                                                            onPressed: () async{
                                                                final xfile = await ImagePicker()
                                                                .pickImage(
                                                                    source: ImageSource.gallery);
                                                            if (xfile != null) {
                                                              setState(() {
                                                                file = xfile;
                                                                isUpdatedPhoto = true;
                                                              });
                                                            } 
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: SvgPicture.asset('assets/icons/icon_send_message.svg'),
                                                            onPressed: () {
                                                              if(messageController.text.isNotEmpty || file !=null){
                                                                 if(chatId == null){
                                                               context.read<ChatBloc>().add(StartChatMessageEvent(userId: widget.interlocutorUserId!, message: messageController.text));
                                                              }else{
                                                             context.read<ChatBloc>().add(SendMessageEvent(
                                                              imagePath: file?.path,
                                                              chatId: chatId!, message: messageController.text,
                                                             isEmptyChat: messages.isEmpty
                                                              ));
                                                              }
                                                              setState(() {
                                                                isUpdatedPhoto = false;
                                                                file = null;
                                                                messageController.clear();
                                                              });
                                                              }
                                                             
                                                            },
                                                          ),
                                                        ],
                                                                                                        ),
                                                                                                      ),
                                                                                            ),
                                                      ],
                                                    ),
                                                  )
                                                                                      
                                                ),
                                              ),
                                        ),
    );
  }

  void scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1), curve: Curves.easeOut);
    }
  }
}
