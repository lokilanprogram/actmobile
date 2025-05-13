import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomNavBar({
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

    return Material(elevation: 1.2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25)
    ),
      child: Container(
        height: 65,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < icons.length; i++)
              GestureDetector(
                onTap: () => onTabSelected(i),
                child: SvgPicture.asset(
                  icons[i],
                  colorFilter: ColorFilter.mode(
                    selectedIndex == i ? mainBlueColor: Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => onTabSelected(3),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/drawer/image.png'),
                backgroundColor: selectedIndex == 3 ? Colors.blue : Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
