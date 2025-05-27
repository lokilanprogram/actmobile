import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';

class TabBarWidget extends StatefulWidget {
  final String selectedTab;
  final Function onTapMine;
  final Function onTapVisited;
  final String firshTabText;
  final String secondTabText;
  final int? requestLentgh;
  final int? recommendedLentgh;

  const TabBarWidget({super.key, required this.selectedTab, required this.onTapMine, required this.onTapVisited,required this.firshTabText, required this.secondTabText,required this.requestLentgh,required this.recommendedLentgh});
  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {

  String _selectedTab = "mine";
  int? requestLenght;
  int? recommendedLenght;


  @override
  void initState() {
    setState(() {
      _selectedTab = widget.selectedTab;
      requestLenght = widget.requestLentgh;
      recommendedLenght = widget.recommendedLentgh;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[200]
      ),height: 33,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = "mine";
                  });
                  widget.onTapMine();
                },
                child: Container(height: 33,
                  decoration: BoxDecoration(
                    color: _selectedTab == "mine" ? mainBlueColor : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      topRight: _selectedTab == "mine"
                          ? Radius.circular(25)
                          : Radius.circular(0),
                      bottomRight: _selectedTab == "mine"
                          ? Radius.circular(25)
                          : Radius.circular(0),
                    ),
                  ),
                  child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.firshTabText,
                          style: TextStyle(
                              color: _selectedTab == "mine" ? Colors.white : Colors.black,
                              fontSize:widget.firshTabText =='Индивидуальные'?18: 19,
                              fontFamily: 'Gilroy',
                              fontWeight:
                                  _selectedTab == "mine" ? FontWeight.bold : FontWeight.w400),
                        ),
                        SizedBox(width: 15,),
                        requestLenght !=null && requestLenght != 0? 
                        lengthWidget(requestLenght!,_selectedTab == 'mine'? Color.fromRGBO(91, 168, 255,1):
                          Color.fromRGBO(194, 194, 194,1),_selectedTab == 'mine'? Colors.white:
                          Color.fromRGBO(102, 102, 102,1),
                          ):Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = "notMine";
                  });
                  widget.onTapVisited();
                },
                child: Container(height: 33,
                  decoration: BoxDecoration(
                    color:
                        _selectedTab == "notMine" ? mainBlueColor : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      bottomLeft: _selectedTab == "notMine"
                          ? Radius.circular(25)
                          : Radius.circular(0),
                      topLeft: _selectedTab == "notMine"
                          ? Radius.circular(25)
                          : Radius.circular(0),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.secondTabText,
                          style: TextStyle(
                              color:
                                  _selectedTab == "notMine" ? Colors.white : Colors.black,
                              fontSize: 19,
                              fontFamily: 'Gilroy',
                              fontWeight: _selectedTab == "notMine"
                                  ? FontWeight.bold
                                  : FontWeight.w400),
                        ),
                        SizedBox(width: 15,),

                        recommendedLenght !=null && recommendedLenght != 0? 
                        lengthWidget(recommendedLenght!,_selectedTab == 'notMine'? Color.fromRGBO(91, 168, 255,1):
                          Color.fromRGBO(194, 194, 194,1),_selectedTab == 'notMine'? Colors.white:
                          Color.fromRGBO(102, 102, 102,1),):Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      
    );
  }

  Container lengthWidget(int length,Color backgroundColor,Color textColor) {
    return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:backgroundColor
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(length.toString(), style: TextStyle(fontSize: 12,
                              fontFamily: 'Gilroy',fontWeight: FontWeight.bold,color: textColor
                            ),),
                          ),
                        ),
                      );
  }
}
