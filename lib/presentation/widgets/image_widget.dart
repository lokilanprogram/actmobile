import 'package:flutter/material.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<String?> imageUrls;
  final int maxVisible;
  final double radius;

  const OverlappingAvatars({
    super.key,
    required this.imageUrls,
    this.maxVisible = 4,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    int extraCount = imageUrls.length - maxVisible;

    List<Widget> avatars = [];

    for (int i = 0; i < imageUrls.length && i < maxVisible; i++) {
      avatars.add(Positioned(
        left: i * (radius), // контролирует overlap
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: radius - 1.5,
            backgroundImage: imageUrls[i] != null
                ? NetworkImage(imageUrls[i]!)
                : AssetImage('assets/images/image_profile.png')
                    as ImageProvider,
            onBackgroundImageError: (_, __) {},
          ),
        ),
      ));
    }

    if (extraCount > 0) {
      avatars.add(Positioned(
        left: maxVisible * radius,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: radius - 1.5,
            backgroundColor: const Color(0xFF4A90E2),
            child: Text(
              '+$extraCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ));
    }

    return SizedBox(
      height: radius * 2,
      width: (radius * (maxVisible * 2)),
      child: Stack(
        children: avatars,
      ),
    );
  }
}

class OverlappingFixedAvatars extends StatelessWidget {
  final List<String?> imageUrls;
  final double size;

  const OverlappingFixedAvatars({
    super.key,
    required this.imageUrls,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final total = imageUrls.length;
    final maxVisible = 4;
    final displayList =
        total <= maxVisible ? imageUrls : imageUrls.sublist(total - maxVisible);

    return SizedBox(
      height: size,
      child: Stack(
        alignment: Alignment.centerRight,
        children: List.generate(displayList.length, (index) {
          final i = displayList.length - 1 - index;
          final imageUrl = displayList[i];

          return Positioned(
            left: index * (size / 2),
            child: ClipOval(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/image_profile.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
