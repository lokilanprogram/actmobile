import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class CustomNavBarWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomNavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<CustomNavBarWidget> createState() => _CustomNavBarWidgetState();
}

class _CustomNavBarWidgetState extends State<CustomNavBarWidget> {
  String? profileIcon;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    final profile = await ProfileApi().getProfile();
    setState(() {
      profileIcon = profile?.photoUrl;
    });
  }

  void _handleTap(int index) {
    FocusScope.of(context).unfocus();
    widget.onTabSelected(index);
  }

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
                onTap: () => _handleTap(i),
                child: SvgPicture.asset(
                  icons[i],
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    widget.selectedIndex == i
                        ? mainBlueColor
                        : Colors.lightBlue.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _handleTap(3),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: profileIcon != null
                    ? NetworkImage(profileIcon!)
                    : AssetImage('assets/images/image_profile.png'),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
