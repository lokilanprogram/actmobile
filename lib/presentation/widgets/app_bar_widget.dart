import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBarWidget({
    super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset('assets/icons/icon_back.svg'),),
      ),
      title: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 23),
        ),
      ),
    );
  }
  
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

