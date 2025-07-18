import 'dart:convert';
import 'dart:async';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/date_utils.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/configs/unread_message_provider.dart';
import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:acti_mobile/data/models/all_chats_snapshot_model.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  AllChatWebSocketService? webSocketService;
  String selectedTab = 'mine';
  AllChatsModel allPrivateChats =
      AllChatsModel(total: 0, offset: 0, limit: 0, chats: []);
  AllChatsModel allGroupChats =
      AllChatsModel(total: 0, offset: 0, limit: 0, chats: []);
  bool _isLoading = false;
  bool isPrivateChats = true;
  bool isVerified = false;
  String? lastProcessedEventId;
  String? userId;
  int _count = 0;
  Map<String, Timer> _typingTimers = {};
  Map<String, String> _originalMessages = {};

  late final ScrollController _scrollControllerPrivate = ScrollController();
  bool isLoadingMorePrivate = false;

  late final ScrollController _scrollControllerGroup = ScrollController();
  bool isLoadingMoreGroup = false;

  @override
  void initState() {
    super.initState();
    _scrollControllerPrivate.addListener(_onScrollPrivate);
    _scrollControllerGroup.addListener(_onScrollGroup);
    initialize();
  }

  Future<void> initialize() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final storage = SecureStorageService();
    final id = await storage.getUserId();
    context.read<ProfileBloc>().add(ProfileGetEvent());
    if (!mounted) return;
    setState(() {
      userId = id;
    });
    // if (verified != true) {
    //   if (!mounted) return;
    //   setState(() {
    //     isVerified = false;
    //     _isLoading = false;
    //   });
    // }
    //   context.read<ChatBloc>().add(GetAllChatsEvent());
    //   final accessToken = await storage.getAccessToken();
    //   webSocketService = AllChatWebSocketService(token: accessToken!);
    // } else {
    //   setState(() {
    //     isVerified = false;
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  void dispose() {
    _scrollControllerPrivate.dispose();
    _scrollControllerGroup.dispose();
    webSocketService?.dispose();
    // Отменяем все активные таймеры
    for (var timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    _originalMessages.clear();
    super.dispose();
  }

  void _onScrollPrivate() {
    final state = context.read<ChatBloc>().state;
    if (_scrollControllerPrivate.position.pixels >=
        _scrollControllerPrivate.position.maxScrollExtent - 200) {
      if (!isLoadingMorePrivate &&
          state is GotAllChatsState &&
          state.hasMorePrivateChats) {
        setState(() => isLoadingMorePrivate = true);
        context.read<ChatBloc>().add(GetAllChatsEvent(loadMorePrivate: true));
      }
    }
  }

  void _onScrollGroup() {
    final state = context.read<ChatBloc>().state;
    if (_scrollControllerGroup.position.pixels >=
        _scrollControllerGroup.position.maxScrollExtent - 200) {
      if (!isLoadingMoreGroup &&
          state is GotAllChatsState &&
          state.hasMoreGroupChats) {
        setState(() => isLoadingMoreGroup = true);
        context.read<ChatBloc>().add(GetAllChatsEvent(loadMoreGroup: true));
      }
    }
  }

  void _resetTypingState(String chatId) {
    if (!mounted) return;

    // Возвращаем последнее сообщение для приватных чатов
    allPrivateChats.chats = allPrivateChats.chats.map((chat) {
      if (chat.id == chatId && chat.lastMessage != null) {
        final originalContent = _originalMessages[chatId];
        return chat.copyWith(
          lastMessage: chat.lastMessage!.copyWith(
            content: originalContent ?? chat.lastMessage!.content,
          ),
        );
      }
      return chat;
    }).toList();

    // Возвращаем последнее сообщение для групповых чатов
    allGroupChats.chats = allGroupChats.chats.map((chat) {
      if (chat.id == chatId && chat.lastMessage != null) {
        final originalContent = _originalMessages[chatId];
        return chat.copyWith(
          lastMessage: chat.lastMessage!.copyWith(
            content: originalContent ?? chat.lastMessage!.content,
          ),
        );
      }
      return chat;
    }).toList();

    // Удаляем таймер и оригинальное сообщение из карт
    _typingTimers.remove(chatId);
    _originalMessages.remove(chatId);

    // Вызываем setState после обновления данных
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadMessageProvider>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is GotAllChatsState) {
              _count = 0;
              _count += state.allGroupChats.chats
                  .where((e) => (e.unreadCount ?? 0) > 0)
                  .length;
              _count += state.allPrivateChats.chats
                  .where((e) => (e.unreadCount ?? 0) > 0)
                  .length;
              unreadProvider.setUnreadCount(_count);
              if (!mounted) return;
              setState(() {
                allGroupChats = state.allGroupChats;
                allPrivateChats = state.allPrivateChats;
                _isLoading = false;
              });
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) async {
            if (state is ProfileGotState) {
              if (webSocketService == null &&
                  state.profileModel.status != 'blocked' &&
                  state.profileModel.isEmailVerified) {
                // Контроллеры уже инициализированы в initState
                final storage = SecureStorageService();
                storage.setUserVerified(true);
                final accessToken = await storage.getAccessToken();
                context.read<ChatBloc>().add(GetAllChatsEvent());
                webSocketService = AllChatWebSocketService(token: accessToken!);
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                  isVerified = state.profileModel.isEmailVerified;
                });
              } else {
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                });
              }
            } else if (state is ProfileResendEmailState) {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Подтверждение отправлено на почту'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is ProfileResendEmailErrorState) {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Чаты',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const LoaderWidget()
            : !isVerified
                ? Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Для продолжения, требуется  подтвердить почту",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 59,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              context
                                  .read<ProfileBloc>()
                                  .add(ProfileGetEvent());
                              if (!mounted) return;
                              setState(() {
                                _isLoading = true;
                              });
                            },
                            child: const Text(
                              'Обновить',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Не пришло уведомление на почту?\n",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Gilroy',
                                  fontSize: 14.7,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: "Отправить еще раз",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context
                                        .read<ProfileBloc>()
                                        .add(ProfileResendEmailEvent());
                                    if (!mounted) return;
                                    setState(() {
                                      _isLoading = true;
                                    });
                                  },
                                style: TextStyle(
                                  color: mainBlueColor,
                                  fontFamily: 'Gilroy',
                                  fontSize: 14.7,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TabBarWidget(
                          selectedTab: selectedTab,
                          onTapMine: () {
                            if (!mounted) return;
                            setState(() => isPrivateChats = true);
                          },
                          onTapVisited: () {
                            if (!mounted) return;
                            setState(() => isPrivateChats = false);
                          },
                          firshTabText: 'Личные',
                          secondTabText: 'Групповые',
                          requestLentgh: null,
                          recommendedLentgh: null,
                        ),
                        const SizedBox(height: 20),
                        if (webSocketService != null)
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
                                    context
                                        .read<ChatBloc>()
                                        .add(GetAllChatsEvent());
                                  } else if (result.eventType ==
                                      'new_message') {
                                    final chatId = result.chatId;
                                    final content =
                                        result.data?.contentPreview ?? " ";
                                    final isFromAnotherUser =
                                        result.data?.senderId != userId;

                                    // PRIVATE CHATS
                                    final private = allPrivateChats.chats;
                                    final updatedPrivate = <Chat>[];

                                    for (var chat in private) {
                                      if (chat.id == chatId) {
                                        if (chat.unreadCount == 0 &&
                                            isFromAnotherUser) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            unreadProvider.increment();
                                          });
                                        }
                                        final updatedChat = chat.copyWith(
                                          unreadCount: isFromAnotherUser
                                              ? (chat.unreadCount ?? 0) + 1
                                              : 0,
                                          lastMessage:
                                              chat.lastMessage!.copyWith(
                                            content: content,
                                            createdAt: DateTime.now(),
                                          ),
                                        );
                                        updatedPrivate.insert(
                                            0, updatedChat); // перемещаем вверх
                                      }
                                    }
                                    allPrivateChats.chats = updatedPrivate;

                                    // GROUP CHATS
                                    final group = allGroupChats.chats;
                                    final updatedGroup = <Chat>[];

                                    for (var chat in group) {
                                      if (chat.id == chatId) {
                                        if (chat.unreadCount == 0 &&
                                            isFromAnotherUser) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            unreadProvider.increment();
                                          });
                                        }
                                        final updatedChat = chat.copyWith(
                                          unreadCount:
                                              (chat.unreadCount ?? 0) + 1,
                                          lastMessage:
                                              chat.lastMessage!.copyWith(
                                            content: content,
                                            createdAt: DateTime.now(),
                                          ),
                                        );
                                        updatedGroup.insert(
                                            0, updatedChat); // перемещаем вверх
                                      }
                                    }
                                    allGroupChats.chats = updatedGroup;

                                    // Обновляем UI после изменения данных
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    });
                                  } else if (result.eventType ==
                                          "user_typing" &&
                                      result.data?.userId != userId &&
                                      result.chatId != null) {
                                    final chatId = result.chatId!;

                                    // Отменяем предыдущий таймер для этого чата, если он существует
                                    _typingTimers[chatId]?.cancel();

                                    // Сохраняем оригинальное сообщение, если еще не сохранено
                                    if (!_originalMessages
                                        .containsKey(chatId)) {
                                      final privateChat = allPrivateChats.chats
                                          .where((chat) => chat.id == chatId)
                                          .firstOrNull;
                                      final groupChat = allGroupChats.chats
                                          .where((chat) => chat.id == chatId)
                                          .firstOrNull;

                                      if (privateChat?.lastMessage != null) {
                                        _originalMessages[chatId] =
                                            privateChat!.lastMessage!.content;
                                      } else if (groupChat?.lastMessage !=
                                          null) {
                                        _originalMessages[chatId] =
                                            groupChat!.lastMessage!.content;
                                      }
                                    }

                                    // Обновляем приватные чаты
                                    allPrivateChats.chats =
                                        allPrivateChats.chats.map((chat) {
                                      if (chat.id == chatId &&
                                          chat.lastMessage != null) {
                                        return chat.copyWith(
                                          lastMessage: chat.lastMessage!
                                              .copyWith(content: 'Печатает...'),
                                        );
                                      }
                                      return chat;
                                    }).toList();

                                    // Обновляем групповые чаты
                                    allGroupChats.chats =
                                        allGroupChats.chats.map((chat) {
                                      if (chat.id == chatId &&
                                          chat.lastMessage != null) {
                                        return chat.copyWith(
                                          lastMessage: chat.lastMessage!
                                              .copyWith(content: 'Печатает...'),
                                        );
                                      }
                                      return chat;
                                    }).toList();

                                    // Запускаем таймер на 1 секунду
                                    _typingTimers[chatId] = Timer(
                                      const Duration(seconds: 1),
                                      () => _resetTypingState(chatId),
                                    );

                                    // Обновляем UI после изменения данных
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    });
                                  }
                                }
                              }
                              return Expanded(child: _buildChatList());
                            },
                          )
                        else
                          Expanded(child: _buildChatList()),
                        SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildChatList() {
    if (isPrivateChats) {
      if (allPrivateChats.chats.isEmpty) {
        return _buildEmptyState('У вас пока нет чатов', showRefresh: true);
      }
      return ListView.builder(
        controller: _scrollControllerPrivate,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: allPrivateChats.chats.length,
        itemBuilder: (context, index) {
          final chat = allPrivateChats.chats[index];
          return ChatListTileWidget(
            onTapFunction: () =>
                context.read<ChatBloc>().add(GetAllChatsEvent()),
            onDeletedFunction: () =>
                context.read<ChatBloc>().add(GetAllChatsEvent()),
            chat: chat,
            isPrivateChats: isPrivateChats,
          );
        },
      );
    } else {
      if (allGroupChats.chats.isEmpty) {
        return _buildEmptyState('У вас пока нет групповых чатов');
      }
      return ListView.builder(
        controller: _scrollControllerGroup,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: allGroupChats.chats.length,
        itemBuilder: (context, index) {
          final chat = allGroupChats.chats[index];
          return ChatListTileWidget(
            onTapFunction: () =>
                context.read<ChatBloc>().add(GetAllChatsEvent()),
            onDeletedFunction: () =>
                context.read<ChatBloc>().add(GetAllChatsEvent()),
            chat: chat,
            isPrivateChats: isPrivateChats,
          );
        },
      );
    }
  }

  Widget _buildEmptyState(String message, {bool showRefresh = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        // if (showRefresh) ...[
        //   const SizedBox(height: 24),
        //   Center(
        //     child: ElevatedButton(
        //       onPressed: initialize,
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: const Color(0xFF4293EF),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(30),
        //         ),
        //         padding:
        //             const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        //       ),
        //       child: const Text(
        //         'Обновить',
        //         style: TextStyle(
        //           fontSize: 16,
        //           color: Colors.white,
        //           fontWeight: FontWeight.w500,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ],
    );
  }
}

class ChatListTileWidget extends StatelessWidget {
  final Chat chat;
  final Function onDeletedFunction;
  final Function onTapFunction;
  final bool isPrivateChats;
  const ChatListTileWidget(
      {required this.onDeletedFunction,
      super.key,
      required this.chat,
      required this.isPrivateChats,
      required this.onTapFunction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: !isPrivateChats
            ? (chat.event!.photos.isNotEmpty
                ? NetworkImage(chat.event!.photos.first)
                : AssetImage('assets/images/image_default_event.png'))
            : (chat.users.isNotEmpty && chat.users.first.photoUrl != null
                ? NetworkImage(chat.users.first.photoUrl!)
                : AssetImage('assets/images/image_profile.png')),
        backgroundColor: Colors.transparent,
      ),
      title: Text(
        !isPrivateChats
            ? "${chat.event!.title} ${DateFormat('dd.MM.yy').format(chat.event!.dateStart)}"
            : (chat.users.isNotEmpty
                ? chat.users.first.name ?? 'not defined'
                : 'Unknown User'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
          chat.unreadCount != null && chat.unreadCount != 0
              ? Container(
                  width: 33,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 66, 147, 239),
                      borderRadius: BorderRadius.all(Radius.circular(108))),
                  child: Text(
                    chat.unreadCount.toString(),
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
        Future.delayed(Duration(milliseconds: 250), () async {
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
                    : (chat.users.isNotEmpty
                        ? chat.users.first.photoUrl
                        : null),
                interlocutorName: !isPrivateChats
                    ? chat.event!.title
                    : (chat.users.isNotEmpty
                        ? chat.users.first.name ?? 'not defined'
                        : 'Unknown User'),
                interlocutorChatId: chat.id,
                interlocutorUserId: !isPrivateChats
                    ? null
                    : (chat.users.isNotEmpty ? chat.users.first.id : null),
              ),
            ),
          );

          if (chat.unreadCount != 0 && chat.unreadCount != null) {
            onTapFunction();
          }
          if (result == true) {
            onDeletedFunction();
          }
        });
      },
    );
  }
}
