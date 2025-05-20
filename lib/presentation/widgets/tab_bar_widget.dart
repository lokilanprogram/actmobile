import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';

class TabBarWidget extends StatefulWidget {
  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  String _selectedTab = "my";

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[200]
      ),
      width: 200,
        child: Row(
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
                  color: _selectedTab == "my" ? mainBlueColor : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    topRight: _selectedTab == "my"
                        ? Radius.circular(25)
                        : Radius.circular(0),
                    bottomRight: _selectedTab == "my"
                        ? Radius.circular(25)
                        : Radius.circular(0),
                  ),
                ),
                child: Text(
                  'Мои',
                  style: TextStyle(
                      color: _selectedTab == "my" ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontFamily: 'Gilroy',
                      fontWeight:
                          _selectedTab == "my" ? FontWeight.w700 : FontWeight.w400),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = "visited";
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                  decoration: BoxDecoration(
                    color:
                        _selectedTab == "visited" ? mainBlueColor : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      bottomLeft: _selectedTab == "visited"
                          ? Radius.circular(25)
                          : Radius.circular(0),
                      topLeft: _selectedTab == "visited"
                          ? Radius.circular(25)
                          : Radius.circular(0),
                    ),
                  ),
                  child: Text(
                    'Посещённые',
                    style: TextStyle(
                        color:
                            _selectedTab == "visited" ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontFamily: 'Gilroy',
                        fontWeight: _selectedTab == "visited"
                            ? FontWeight.w700
                            : FontWeight.w400),
                  ),
                ),
              ),
            ),
          ],
        ),
      
    );
  }
}
