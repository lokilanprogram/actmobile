import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomNavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      'assets/drawer/location.svg',
      'assets/drawer/events.svg',
      'assets/drawer/chats.svg',
    ];

    return Material(
      elevation: 8,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 65,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < icons.length; i++)
              GestureDetector(
                onTap: () => onTabSelected(i),
                child: SvgPicture.asset(
                  icons[i],
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == i ? mainBlueColor : Colors.lightBlue.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => onTabSelected(3),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/drawer/image.png'),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
