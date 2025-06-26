import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/chat_info_model.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/message_card.dart';
import 'package:acti_mobile/presentation/widgets/toggle_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  String? interlocutorName;
  bool? isPrivateChats;
  String? trailingText;
  String? interlocutorAvatar;
  final String interlocutorChatId;
  String? interlocutorUserId;
  ChatDetailScreen(
      {super.key,
      this.isPrivateChats,
      this.interlocutorAvatar,
      this.interlocutorName,
      required this.interlocutorChatId,
      this.interlocutorUserId,
      this.trailingText});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChatWebSocketService? webSocketService;
  final messageController = TextEditingController();
  final seacrhController = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool isSearching = false;
  String searchText = '';
  List<MessageModel> filteredMessages = [];
  int currentSearchIndex = 0;
  final Map<String, GlobalKey> _messageKeys = {};

  final picker = ImagePicker();
  bool isSearched = false;
  bool isMe = false;
  bool isLoading = false;

  String? chatId;
  String? profileUserId;

  List<MessageModel> messages = [];
  int total = 0;
  String? interlocutorName;
  String? interlocutorAvatar;
  String? trailing;
  late bool isPrivate;

  String? status = "Офлайн";

  XFile? file;
  bool isUpdatedPhoto = false;

  bool isReaded = false;

  bool isScroll = false;

  ChatInfoModel? chatInfo;
  bool isOk = false;
  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  initialize() async {
    setState(() {
      isLoading = true;
    });

    final storage = SecureStorageService();
    final userId = await storage.getUserId();
    final accessToken = await storage.getAccessToken();

    if (widget.interlocutorChatId != "") {
      context
          .read<ChatBloc>()
          .add(GetChatHistoryEvent(chatId: widget.interlocutorChatId));
    } else {
      setState(() {
        isLoading = false;
        isOk = true;
      });
    }

    if (widget.interlocutorChatId != "" && widget.interlocutorName != '...') {
      webSocketService = ChatWebSocketService(
        chatId: widget.interlocutorChatId,
        token: accessToken!,
      );
    } else if (widget.interlocutorChatId != "" &&
        widget.interlocutorName == '...' &&
        widget.interlocutorUserId == null &&
        widget.interlocutorAvatar == null &&
        widget.trailingText == null) {
      webSocketService = ChatWebSocketService(
        chatId: widget.interlocutorChatId,
        token: accessToken!,
      );
      context
          .read<ChatBloc>()
          .add(GetChatFromPushHistoryEvent(chatId: widget.interlocutorChatId));
    }

    setState(() {
      profileUserId = userId;
      trailing = widget.trailingText;
      chatId = widget.interlocutorChatId;
      interlocutorName = widget.interlocutorName;
      interlocutorAvatar = widget.interlocutorAvatar;
    });
  }

  @override
  dispose() {
    messages.clear();
    chatId = null;
    trailing = null;
    interlocutorAvatar = null;
    interlocutorName = null;
    profileUserId = null;
    webSocketService?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        messages.length < (total ?? 0) &&
        isLoad) {
      setState(() {
        isLoad = false;
      });
      context.read<ChatBloc>().add(
            GetChatHistoryEvent(chatId: chatId!, isLoadMore: true),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isScroll && messages.isNotEmpty)
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToEnd());

    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is SentMessageState) {
              if (state.chatModel != null) {
                setState(() {
                  messages = state.chatModel!.messages;
                  isScroll = false;
                });
                scrollToEnd();
              } else {
                setState(() {
                  isScroll = false;
                });
              }
            }
            if (state is SentMessageErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
            if (state is StartedChatMessageState) {
              setState(() {
                webSocketService = ChatWebSocketService(
                  chatId: state.chatId,
                  token: state.accessToken,
                );
                messages = state.chatModel.messages;
                chatId = state.chatId;
              });
              scrollToEnd();
            }
            if (state is GotChatHistoryState) {
              if (state.chatInfoModel.users!.isEmpty &&
                  state.chatInfoModel.type == "private") {
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Пользователь удален"),
                  ),
                );
              } else {
                setState(() {
                  state.chatInfoModel.type == "private" &&
                          state.chatInfoModel.users?.first.status == "online"
                      ? status = "Онлайн"
                      : "Офлайн";
                  isLoading = false;
                  chatInfo = state.chatInfoModel;
                  messages = state.chatModel.messages;
                  isPrivate = state.chatInfoModel.users?.length == 1;
                  isOk = true;
                  total = state.chatModel.total;
                  isLoad = true;
                });
              }
              // if (!state.chatModel.messages.isEmpty && !state.isLoadMore) {
              //   scrollToEnd();
              // }
            }

            if (state is DeletedChatState) {
              setState(() {
                isLoading = false;
              });
              webSocketService?.dispose();
              Navigator.pop(context, true);
            }

            if (state is CreatedChatState) {
              setState(() {
                webSocketService = ChatWebSocketService(
                  chatId: state.chatId,
                  token: state.accessToken,
                );
                messages = state.chatModel.messages;
                total = state.chatModel.total;
                isLoading = false;
              });
              chatId = state.chatId;
            }
            if (state is CreatedChatErrorState) {
              setState(() {
                isLoading = false;
              });
            }
            if (state is GotChatHistoryErrorState) {
              setState(() {
                isLoading = false;
              });
            }

            if (state is DeletedChatErrorState) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            // TODO: implement listener
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: isSearched
                ? AppBar(
                    scrolledUnderElevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    title: Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1.2,
                              color: Colors.blue,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSearched = false;
                                  });
                                },
                                icon: Icon(Icons.arrow_back_ios),
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  autofocus: true,
                                  controller: seacrhController,
                                  onChanged: filterMessages,
                                  decoration: InputDecoration(
                                    hintText: 'Поиск',
                                    isDense: true,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_upward),
                                onPressed: currentSearchIndex > 0
                                    ? goToPreviousSearchResult
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_downward),
                                onPressed: currentSearchIndex <
                                        filteredMessages.length - 1
                                    ? goToNextSearchResult
                                    : null,
                              ),
                            ],
                          ),
                        )),
                  )
                : AppBar(
                    backgroundColor: Colors.white,
                    scrolledUnderElevation: 0,
                    shadowColor: Colors.transparent,
                    titleSpacing: 1.3,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          icon: Icon(Icons.arrow_back_ios)),
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
                              onTap: () async {
                                if (!mounted) return;
                                await Future.delayed(
                                    Duration(milliseconds: 300));
                                setState(() {
                                  isSearched = true;
                                });
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                      'assets/icons/icon_search.svg'),
                                  SizedBox(width: 10),
                                  Text(
                                    "Поиск",
                                    style: TextStyle(
                                        fontFamily: 'Gilroy',
                                        fontSize: 12.93,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 0,
                              onTap: () {
                                if (chatId != null) {
                                  showBlockDialog(
                                      context,
                                      'Удалить диалог?',
                                      trailing != null
                                          ? 'Вы точно хотите удалить групповой чат?'
                                          : 'Вы точно хотите удалить диалог c пользователем //?',
                                      () async {
                                    if (!mounted) return;
                                    await Future.delayed(
                                        Duration(milliseconds: 300));
                                    setState(() {
                                      isLoading = true;
                                    });
                                    context
                                        .read<ChatBloc>()
                                        .add(DeleteChatEvent(chatId: chatId!));
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                      'assets/icons/icon_delete.svg'),
                                  SizedBox(width: 10),
                                  Text(
                                    "Удалить у всех",
                                    style: TextStyle(
                                        fontFamily: 'Gilroy',
                                        fontSize: 12.93,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child:
                              const Icon(Icons.more_vert, color: Colors.black),
                        ),
                      ),
                    ],
                    title: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () {
                                Future.delayed(Duration(milliseconds: 250),
                                    () async {
                                  if (chatInfo?.eventId == null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PublicUserScreen(
                                                    userId: (widget
                                                                .interlocutorUserId !=
                                                            null)
                                                        ? widget
                                                            .interlocutorUserId!
                                                        : (chatInfo?.users !=
                                                                    null &&
                                                                chatInfo!.users!
                                                                    .isNotEmpty)
                                                            ? chatInfo!
                                                                .users!.first.id
                                                            : "")));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EventDetailScreen(
                                                  eventId: widget
                                                          .interlocutorUserId ??
                                                      chatInfo!.eventId ??
                                                      "",
                                                )));
                                  }
                                });
                              },
                              child: chatInfo?.event == null &&
                                      (chatInfo?.users == null ||
                                          chatInfo!.users!.isEmpty ||
                                          chatInfo?.users?.first.photoUrl ==
                                              null)
                                  ? CircleAvatar(
                                      maxRadius: 26,
                                      backgroundImage: AssetImage(
                                        'assets/images/image_profile.png',
                                      ))
                                  : (chatInfo?.event?.photos == null ||
                                              chatInfo?.event?.photos
                                                      ?.isEmpty ==
                                                  true) &&
                                          (chatInfo?.users == null ||
                                              chatInfo!.users!.isEmpty ||
                                              chatInfo?.users?.first.photoUrl ==
                                                  null)
                                      ? CircleAvatar(
                                          maxRadius: 26,
                                          backgroundImage: AssetImage(
                                            'assets/images/image_default_event.png',
                                          ))
                                      : (chatInfo?.event?.photos != null &&
                                              chatInfo!
                                                  .event!.photos!.isNotEmpty)
                                          ? CircleAvatar(
                                              maxRadius: 26,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                chatInfo!.event!.photos!.first,
                                              ),
                                            )
                                          : (chatInfo?.users != null &&
                                                  chatInfo!.users!.isNotEmpty &&
                                                  chatInfo!.users!.first
                                                          .photoUrl !=
                                                      null)
                                              ? CircleAvatar(
                                                  maxRadius: 26,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    chatInfo!
                                                        .users!.first.photoUrl!,
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  maxRadius: 26,
                                                  backgroundImage: AssetImage(
                                                    'assets/images/image_profile.png',
                                                  )),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  chatInfo?.event != null
                                      ? Text(
                                          chatInfo?.event?.title ?? '...',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 17.14,
                                              overflow: TextOverflow.visible,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : (chatInfo?.users != null &&
                                              chatInfo!.users!.isNotEmpty)
                                          ? Text(
                                              chatInfo?.users!.first.name ??
                                                  '...',
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 17.14,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              widget.interlocutorName ?? '...',
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 17.14,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                  SizedBox(
                                    height: status != null ? 5 : 0,
                                  ),
                                  chatInfo != null
                                      ? Text(
                                          chatInfo?.type == 'private'
                                              ? status ?? ""
                                              : "",
                                          style: TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontSize: 16,
                                          ),
                                        )
                                      : Text(
                                          chatInfo?.type == 'private'
                                              ? 'Оффлайн'
                                              : '',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            body: isLoading || isOk == false
                ? LoaderWidget()
                : SafeArea(
                    child: Column(
                      children: [
                        if (chatInfo?.type == "private" &&
                            chatInfo?.users != null &&
                            chatInfo!.users!.isNotEmpty &&
                            chatInfo!.users!.first.hasRecentBan == true)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, top: 5),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                'На данного пользователя поступали жалобы, будьте бдительны',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 5),
                            child: messages.isEmpty
                                ? const SizedBox()
                                : StreamBuilder(
                                    stream: webSocketService!.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final result =
                                            ChatSnapshotModel.fromJson(
                                                jsonDecode(snapshot.data));
                                        if (result.type == 'new_message') {
                                          print(result);

                                          final newMessage = result.message;
                                          if (result.message?.userId !=
                                              profileUserId) {
                                            status = "Онлайн";
                                          }

                                          final alreadyExists = messages.any(
                                              (m) => m.id == newMessage!.id);
                                          if (!alreadyExists) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              setState(() {
                                                messages.add(newMessage!);
                                              });
                                            });
                                          }
                                        } else if (result.type ==
                                                'user_typing' &&
                                            result.userId != profileUserId &&
                                            result.userId != null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              status = "Печатает...";
                                              for (var i in messages) {
                                                i.status = "read";
                                              }
                                              isReaded = true;
                                            });
                                          });
                                          print(result);
                                        } else if (result.type ==
                                            "message_deleted") {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              messages.removeWhere((m) =>
                                                  m.id ==
                                                  jsonDecode(snapshot.data)[
                                                      'message_id']);
                                            });
                                          });
                                        } else if (result.type ==
                                                'user_joined' &&
                                            result.userId != profileUserId &&
                                            result.userId != null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              status = "Онлайн";
                                              for (var i in messages) {
                                                i.status = "read";
                                              }
                                              isReaded = true;
                                            });
                                          });
                                          print(result);
                                        } else if (result.type == 'user_left' &&
                                            result.userId != profileUserId &&
                                            result.userId != null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              status = "Офлайн";
                                            });
                                          });
                                          print(result);
                                        } else if (result.type ==
                                                'user_joined' &&
                                            result.userId != profileUserId) {
                                          status = "Онлайн";
                                        } else if (result.type == 'user_left' &&
                                            result.userId != profileUserId) {
                                          status = "Офлайн";
                                        }
                                      }

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        reverse: true,
                                        itemCount: messages.length +
                                            (isLoading ? 1 : 0),
                                        controller: scrollController,
                                        itemBuilder: (context, index) {
                                          if (index == messages.length) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          final message = messages[
                                              messages.length - 1 - index];
                                          final isMe =
                                              message.userId == profileUserId;
                                          final hasAttachment =
                                              message.attachmentUrl != null;
                                          final isLongText =
                                              message.content.length > 40;

                                          final isFirstMsg = index == 0;
                                          final isSpecial = isFirstMsg ||
                                              (index > 0 &&
                                                  messages[messages.length -
                                                              1 -
                                                              index]
                                                          .userId !=
                                                      messages[messages.length -
                                                              1 -
                                                              (index - 1)]
                                                          .userId);

                                          final key =
                                              _messageKeys[message.id] ??=
                                                  GlobalKey();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: AnimatedSwitcher(
                                              duration:
                                                  Duration(milliseconds: 300),
                                              transitionBuilder:
                                                  (child, animation) =>
                                                      FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                              child:
                                                  messages[messages.length -
                                                                  1 -
                                                                  index]
                                                              .id !=
                                                          null
                                                      ? Column(
                                                          crossAxisAlignment: isMe
                                                              ? CrossAxisAlignment
                                                                  .end
                                                              : CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment: isMe
                                                                  ? Alignment
                                                                      .centerRight
                                                                  : Alignment
                                                                      .centerLeft,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    BoxConstraints(
                                                                  maxWidth: (hasAttachment ||
                                                                          isLongText)
                                                                      ? MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.85
                                                                      : MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.47,
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: isMe
                                                                      ? MainAxisAlignment
                                                                          .end
                                                                      : MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    if (chatInfo?.type ==
                                                                            "group" &&
                                                                        isMe ==
                                                                            false)
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () {
                                                                          Future.delayed(
                                                                              Duration(milliseconds: 250),
                                                                              () async {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => PublicUserScreen(userId: message.userId)));
                                                                          });
                                                                        },
                                                                        child: chatInfo ==
                                                                                null
                                                                            ? CircleAvatar(
                                                                                maxRadius: 26,
                                                                                backgroundImage: AssetImage(
                                                                                  'assets/images/image_profile.png',
                                                                                ))
                                                                            : message.user.photoUrl == null || message.user.photoUrl == ""
                                                                                ? CircleAvatar(
                                                                                    maxRadius: 26,
                                                                                    backgroundImage: AssetImage(
                                                                                      'assets/images/image_profile.png',
                                                                                    ))
                                                                                : CircleAvatar(
                                                                                    maxRadius: 26,
                                                                                    backgroundImage: CachedNetworkImageProvider(
                                                                                      message.user.photoUrl!,
                                                                                    ),
                                                                                  ),
                                                                      ),
                                                                    Expanded(
                                                                      child: isMe
                                                                          ? ToggleMessage(
                                                                              deleteMessage: () {
                                                                                context.read<ChatBloc>().add(DeleteMessageEvent(messageId: message.id));
                                                                              },
                                                                              message: message.content,
                                                                              scrollController: scrollController,
                                                                              child: MessageCard(
                                                                                key: key,
                                                                                isPrivateChats: widget.isPrivateChats ?? isPrivate,
                                                                                orgId: chatInfo?.creatorId ?? "",
                                                                                message: message,
                                                                                currentUserId: profileUserId!,
                                                                                special: isSpecial,
                                                                                highlightText: isSearching ? searchText : null,
                                                                                isHighlighted: isSearching && filteredMessages.isNotEmpty && message.id == filteredMessages[currentSearchIndex].id,
                                                                                isReaded: isReaded,
                                                                              ),
                                                                            )
                                                                          : MessageCard(
                                                                              key: key,
                                                                              isPrivateChats: widget.isPrivateChats ?? isPrivate,
                                                                              orgId: chatInfo?.creatorId ?? "",
                                                                              message: message,
                                                                              currentUserId: profileUserId!,
                                                                              special: isSpecial,
                                                                              highlightText: isSearching ? searchText : null,
                                                                              isHighlighted: isSearching && filteredMessages.isNotEmpty && message.id == filteredMessages[currentSearchIndex].id,
                                                                              isReaded: isReaded,
                                                                            ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : SizedBox.shrink(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                        if (!isSearched) inputMessage(context),
                      ],
                    ),
                  )),
      ),
    );
  }

  Widget inputMessage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      width: double.infinity,
      child: Padding(
        padding:
            const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 50),
        child: Container(
          decoration: BoxDecoration(
              color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Padding(
                padding: EdgeInsets.all(isUpdatedPhoto ? 8.0 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isUpdatedPhoto
                        ? Stack(
                            children: [
                              Positioned(
                                child: Image.file(
                                  File(file!.path),
                                  fit: BoxFit.cover,
                                  height: 85,
                                  width: 85,
                                ),
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
                                  child: Container(
                                    width: 20,
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
                          )
                        : Container(),
                    Stack(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: TextFormField(
                            controller: messageController,
                            onChanged: (value) {
                              webSocketService?.sendTyping();
                            },
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Сообщение',
                              filled: true,
                              fillColor: const Color(0xFFF2F2F2),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 16, 90, 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: SvgPicture.asset(
                                    'assets/icons/icon_pin_files.svg'),
                                onPressed: () async {
                                  final xfile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (xfile != null) {
                                    setState(() {
                                      file = xfile;
                                      isUpdatedPhoto = true;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                    'assets/icons/icon_send_message.svg'),
                                onPressed: () {
                                  final messageText =
                                      messageController.text.trim();
                                  final hasMessage =
                                      messageText.isNotEmpty || file != null;

                                  if (!hasMessage) return;

                                  if (chatId == null || chatId == "") {
                                    context.read<ChatBloc>().add(
                                          StartChatMessageEvent(
                                            imagePath: file?.path,
                                            userId: widget.interlocutorUserId!,
                                            message: messageText,
                                          ),
                                        );
                                  } else {
                                    context.read<ChatBloc>().add(
                                          SendMessageEvent(
                                            imagePath: file?.path,
                                            chatId: chatId!,
                                            message: messageText,
                                            isEmptyChat: messages.isEmpty,
                                          ),
                                        );
                                  }

                                  setState(() {
                                    isUpdatedPhoto = false;
                                    file = null;
                                    messageController.clear();
                                  });

                                  webSocketService?.sendOnline();
                                  scrollToEnd();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  void scrollToEnd() {
    if (scrollController.hasClients && messages.isNotEmpty) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      isScroll = true;
    }
  }

  void filterMessages(String text) {
    setState(() {
      searchText = text;
      if (text.isEmpty) {
        isSearching = false;
        filteredMessages.clear();
        currentSearchIndex = 0;
      } else {
        isSearching = true;
        filteredMessages = messages.where((msg) {
          return msg.content.toLowerCase().contains(text.toLowerCase());
        }).toList();
        currentSearchIndex = filteredMessages.length - 1;

        if (filteredMessages.isNotEmpty) {
          scrollToSearchedMessage(currentSearchIndex);
        }
      }
    });
  }

  void goToNextSearchResult() {
    if (filteredMessages.isEmpty) return;
    if (currentSearchIndex < filteredMessages.length - 1) {
      setState(() {
        currentSearchIndex++;
      });
      scrollToSearchedMessage(currentSearchIndex);
    }
  }

  void goToPreviousSearchResult() {
    if (currentSearchIndex > 0) {
      setState(() {
        currentSearchIndex--;
      });
      scrollToSearchedMessage(currentSearchIndex);
    }
  }

  void scrollToSearchedMessage(int index) {
    if (index < 0 || index >= filteredMessages.length) return;

    final messageId = filteredMessages[index].id;
    final key = _messageKeys[messageId];

    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
