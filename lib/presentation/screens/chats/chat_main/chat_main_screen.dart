import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  String selectedTab = 'mine';
  late AllChatsModel allPrivateChats;
  late AllChatsModel allGroupChats;
  bool isLoading = false;
  @override
  void initState() {
    initialize();
    super.initState();
  }
  initialize(){
    setState(() {
      isLoading = true;
    });
    context.read<ChatBloc>().add(GetAllChatsEvent());
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if(state is GotAllChatsState){
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
        body:isLoading? LoaderWidget(): Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: ListView(
            children: [
              TabBarWidget(
                  selectedTab: selectedTab,
                  onTapMine: () {},
                  onTapVisited: () {},
                  firshTabText: 'Индивидуальные',
                  secondTabText: 'Групповые',
                  requestLentgh: null,
                  recommendedLentgh: null),
              SizedBox(
                height: 20,
              ),
              Column(
                children: allPrivateChats.chats.map((chat){
                  return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage:chat.users.last.photoUrl==null?
                  AssetImage('assets/images/image_profile.png'):
                  NetworkImage(chat.users.last.photoUrl!),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(
                  chat.users.last.name,
                  style: TextStyle(
                    fontFamily: 'Inter',fontWeight: FontWeight.bold,
                    fontSize: 17
                  ),
                ),
                subtitle: Text(chat.lastMessage?.content ??'...',
                style: TextStyle(
                    fontFamily: 'Inter',fontWeight: FontWeight.w500,
                    fontSize: 15
                  ),),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                                publicUserModel: null,
                                userId: null,
                              )));
                },
              );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
