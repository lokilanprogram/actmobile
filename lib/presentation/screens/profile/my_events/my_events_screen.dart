import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/events_home_widget.dart';
import 'package:flutter/material.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(leading: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,size: 22,)),
      ),title: Align(
        alignment: Alignment.topLeft,
        child: Text('События',
        style: TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.bold,fontSize:23 ),),
      ),),
      body: SafeArea(child: 
      Padding( padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
        child: ListView(
          children: [
            TabBarWidget(),
            Container(
                decoration: BoxDecoration(
                 color: Colors.grey[200],borderRadius: BorderRadius.circular(25)
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.search,color: Colors.grey,),
                    hintText: 'Поиск',hintStyle: TextStyle(fontFamily: 'Gilroy',fontSize: 16,
                    fontWeight: FontWeight.w400)
                  ),
                ),
              ),
            SizedBox(height: 25,),
            CardEventWidget(),
            CardEventWidget(),
            CardEventWidget(),
            
          ],
        ),
      ))
    );
  }
}

class TabBarWidget extends StatefulWidget {
  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  String _selectedTab = "my";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = "my";
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
            decoration: BoxDecoration(
              color: _selectedTab == "my" ? mainBlueColor : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                topRight:_selectedTab == "my" ? Radius.circular(25):Radius.circular(0),
                bottomRight:_selectedTab == "my" ? Radius.circular(25):Radius.circular(0),
              ),
            ),
            child: Text(
              'Мои',
              style: TextStyle(
                color: _selectedTab == "my" ? Colors.white : Colors.black,
                fontSize: 18,
                fontFamily: 'Gilroy',
                fontWeight: _selectedTab == "my" ?FontWeight.w700:FontWeight.w400
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = "visited";
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
            decoration: BoxDecoration(
              color: _selectedTab == "visited" ? mainBlueColor: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
                bottomLeft:_selectedTab == "visited" ? Radius.circular(25):Radius.circular(0),
                topLeft:_selectedTab == "visited" ? Radius.circular(25):Radius.circular(0),
              ),
            ),
            child: Text(
              'Посещённые',
              style: TextStyle(
                color: _selectedTab == "visited" ? Colors.white : Colors.black,
                fontSize: 18,
                fontFamily: 'Gilroy',
                fontWeight: _selectedTab == "visited" ?FontWeight.w700:FontWeight.w400
              ),
            ),
          ),
        ),
      ],
    );
  }
}