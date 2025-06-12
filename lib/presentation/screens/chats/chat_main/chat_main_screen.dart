import 'dart:convert';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/date_utils.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:acti_mobile/data/models/all_chats_snapshot_model.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  AllChatWebSocketService? webSocketService;
  String selectedTab = 'mine';
  late AllChatsModel allPrivateChats;
  late AllChatsModel allGroupChats;
  bool isLoading = false;
  bool isPrivateChats = true;
  late bool isVerified;
  String? lastProcessedEventId;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    isLoading = true;
    isVerified = true;

    final storage = SecureStorageService();
    final verified = await storage.isUserVerified();
    if (verified == true) {
      context.read<ChatBloc>().add(GetAllChatsEvent());
      final accessToken = await storage.getAccessToken();
      webSocketService = AllChatWebSocketService(token: accessToken!);
    } else {
      isVerified = false;
      isLoading = false;
    }
  }

  @override
  void dispose() {
    webSocketService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is GotAllChatsState) {
          setState(() {
            allGroupChats = state.allGroupChats;
            allPrivateChats = state.allPrivateChats;
            isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Чаты',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: isLoading
            ? LoaderWidget()
            : !isVerified
                ? Center(
                    child: Text(
                    "Подтвердите почту",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: mainBlueColor,
                        fontSize: 18.35,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter'),
                  ))
                : Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: ListView(
                      children: [
                        TabBarWidget(
                            selectedTab: selectedTab,
                            onTapMine: () {
                              setState(() {
                                isPrivateChats = true;
                              });
                            },
                            onTapVisited: () {
                              setState(() {
                                isPrivateChats = false;
                              });
                            },
                            firshTabText: 'Личные',
                            secondTabText: 'Групповые',
                            requestLentgh: null,
                            recommendedLentgh: null),
                        SizedBox(
                          height: 20,
                        ),
                        StreamBuilder(
                            stream: webSocketService!.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final data = snapshot.data!;
                                final result = AllChatsSnapshotModel.fromJson(
                                    jsonDecode(data));

                                if (result.timestamp != lastProcessedEventId) {
                                  lastProcessedEventId = result.timestamp;

                                  if (result.eventType == "new_chat") {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      context
                                          .read<ChatBloc>()
                                          .add(GetAllChatsEvent());
                                    });
                                  } else if (result.eventType ==
                                      'new_message') {
                                    allPrivateChats.chats =
                                        allPrivateChats.chats.map((chat) {
                                      if (chat.id == result.chatId &&
                                          chat.lastMessage != null) {
                                        return chat.copyWith(
                                          unreadCount: chat.unreadCount! + 1,
                                          lastMessage:
                                              chat.lastMessage!.copyWith(
                                            content:
                                                result.data?.contentPreview ??
                                                    "...",
                                          ),
                                        );
                                      }
                                      return chat;
                                    }).toList();
                                    allGroupChats.chats =
                                        allGroupChats.chats.map((chat) {
                                      if (chat.id == result.chatId &&
                                          chat.lastMessage != null) {
                                        return chat.copyWith(
                                          unreadCount:
                                              chat.unreadCount ?? 0 + 1,
                                          lastMessage: chat.lastMessage!
                                              .copyWith(
                                                  content: result.data
                                                          ?.contentPreview ??
                                                      "..."),
                                        );
                                      }
                                      return chat;
                                    }).toList();
                                  } else if (result.eventType ==
                                      "user_typing") {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      allPrivateChats.chats =
                                          allPrivateChats.chats.map((chat) {
                                        if (chat.id == result.chatId &&
                                            chat.lastMessage != null) {
                                          return chat.copyWith(
                                            lastMessage: chat.lastMessage!
                                                .copyWith(
                                                    content: 'Печатает...'),
                                          );
                                        }
                                        return chat;
                                      }).toList();
                                      allGroupChats.chats =
                                          allGroupChats.chats.map((chat) {
                                        if (chat.id == result.chatId &&
                                            chat.lastMessage != null) {
                                          return chat.copyWith(
                                            lastMessage: chat.lastMessage!
                                                .copyWith(
                                                    content: 'Печатает...'),
                                          );
                                        }
                                        return chat;
                                      }).toList();
                                    });
                                  }
                                }
                              }
                              return isPrivateChats == true
                                  ? (allPrivateChats.chats.isEmpty
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 100),
                                            Center(
                                              child: Text(
                                                'У вас пока нет чатов',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  initialize();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF4293EF),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 32),
                                                ),
                                                child: Text(
                                                  'Обновить',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children:
                                              allPrivateChats.chats.map((chat) {
                                            return ChatListTileWidget(
                                              onDeletedFunction: () {
                                                context
                                                    .read<ChatBloc>()
                                                    .add(GetAllChatsEvent());
                                              },
                                              chat: chat,
                                              isPrivateChats: isPrivateChats,
                                            );
                                          }).toList(),
                                        ))
                                  : (allGroupChats.chats.isEmpty
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 100),
                                            Center(
                                              child: Text(
                                                'У вас пока нет групповых чатов',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                          ],
                                        )
                                      : Column(
                                          children:
                                              allGroupChats.chats.map((chat) {
                                            return ChatListTileWidget(
                                              onDeletedFunction: () {
                                                context
                                                    .read<ChatBloc>()
                                                    .add(GetAllChatsEvent());
                                              },
                                              chat: chat,
                                              isPrivateChats: isPrivateChats,
                                            );
                                          }).toList(),
                                        ));
                            }),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class ChatListTileWidget extends StatelessWidget {
  final Chat chat;
  final Function onDeletedFunction;
  final bool isPrivateChats;
  const ChatListTileWidget(
      {required this.onDeletedFunction,
      super.key,
      required this.chat,
      required this.isPrivateChats});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: !isPrivateChats
            ? (chat.event!.photos.isNotEmpty
                ? NetworkImage(chat.event!.photos.first)
                : AssetImage('assets/images/image_default_event.png'))
            : (chat.users.first.photoUrl == null
                ? AssetImage('assets/images/image_profile.png')
                : NetworkImage(
                    chat.users.first.photoUrl!,
                  )),
        backgroundColor: Colors.transparent,
      ),
      title: Text(
        !isPrivateChats
            ? "${chat.event!.title} ${DateFormat('dd.MM.yy').format(chat.event!.dateStart)}"
            : chat.users.first.name ?? 'not defined',
        style: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 17),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formattedTimestamp(
              chat.lastMessage?.createdAt.toLocal() ?? chat.createdAt.toLocal(),
            ),
            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
          ),
          chat?.unreadCount != null && chat?.unreadCount != 0
              ? Container(
                  width: 33,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 66, 147, 239),
                      borderRadius: BorderRadius.all(Radius.circular(108))),
                  child: Text(
                    chat!.unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                )
              : Container(
                  width: 33,
                ),
        ],
      ),
      subtitle: Text(
        chat.status != null
            ? chat.status ?? chat.lastMessage?.content ?? '...'
            : chat.lastMessage?.content ?? '...',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Color.fromRGBO(102, 102, 102, 1)),
      ),
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                      isPrivateChats: isPrivateChats,
                      trailingText: !isPrivateChats
                          ? '${DateFormat('dd.MM.yyyy').format(chat.event!.dateStart)} | ${chat.event!.timeStart.substring(0, 5)} – ${chat.event!.timeEnd.substring(0, 5)}'
                          : null,
                      interlocutorAvatar: !isPrivateChats
                          ? chat.event!.photos.isNotEmpty
                              ? chat.event!.photos.first
                              : null
                          : chat.users.first.photoUrl,
                      interlocutorName: !isPrivateChats
                          ? chat.event!.title
                          : (chat.users.first.name ?? 'not defined'),
                      interlocutorChatId: chat.id,
                      interlocutorUserId:
                          !isPrivateChats ? null : (chat.users.first.id),
                    )));
        if (result == true) {
          onDeletedFunction();
        }
      },
    );
  }
}
