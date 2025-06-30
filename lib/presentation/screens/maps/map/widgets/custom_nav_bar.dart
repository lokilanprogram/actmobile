import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/unread_message_provider.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomNavBarWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final String? profileIconUrl;

  const CustomNavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.profileIconUrl,
  });

  @override
  State<CustomNavBarWidget> createState() => _CustomNavBarWidgetState();
}

class _CustomNavBarWidgetState extends State<CustomNavBarWidget> {
  @override
  Widget build(BuildContext context) {
    final icons = [
      'assets/drawer/location.svg',
      'assets/drawer/events.svg',
      'assets/drawer/chats.svg',
      'assets/drawer/profile.svg',
    ];

    final unreadProvider = Provider.of<UnreadMessageProvider>(context);
    final count = unreadProvider.unreadCount;

    return SafeArea(
      top: false,
      child: Material(
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
                  child: i == 3
                      ? CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: widget.profileIconUrl != null &&
                                    widget.profileIconUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: widget.profileIconUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.person,
                                          color: Colors.grey),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/image_profile.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )
                      : SizedBox(
                          height: 31.5,
                          width: 31.5,
                          child: Stack(
                            children: [
                              SvgPicture.asset(
                                icons[i],
                                height: 28,
                                colorFilter: ColorFilter.mode(
                                  widget.selectedIndex == i ||
                                          (i == 3 && widget.selectedIndex == 4)
                                      ? const Color.fromARGB(255, 0, 107, 221)
                                      : mainBlueColor.withAlpha(130),
                                  BlendMode.srcIn,
                                ),
                              ),
                              if (i == 2 && count > 0)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    constraints: BoxConstraints(
                                        maxHeight: 15, minWidth: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      count.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    FocusScope.of(context).unfocus();
    // При нажатии на иконку профиля всегда переходим на индекс 3
    if (index == 3) {
      widget.onTabSelected(3);
    } else {
      widget.onTabSelected(index);
    }
  }
}
