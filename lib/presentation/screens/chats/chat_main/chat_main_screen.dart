import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  String selectedTab = 'mine';
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.topLeft,
          child: Text('Чаты',style: TextStyle(
            fontFamily: 'Inter',fontSize: 23, fontWeight: FontWeight.bold
          ),),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20,left: 20),
        child: Column(
            children: [
              TabBarWidget(selectedTab: selectedTab, onTapMine: (){}, onTapVisited: (){}, firshTabText: 'Индивидуальные',
               secondTabText: 'Групповые', requestLentgh: null, recommendedLentgh: null),
               SizedBox(height: 20,),
               ListTile(leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/image_profile.png'),
                  backgroundColor: Colors.transparent,
                ),title: Text('Анастасия',),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatDetailScreen(publicUserModel: null,userId: null,)));
                },
                )
            ],
          
        ),
      ),
    );
  }
}