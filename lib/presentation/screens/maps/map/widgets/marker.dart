import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryMarker extends StatelessWidget {
  final String iconUrl;
  final String title;
  final double opacity;

  const CategoryMarker({
    super.key,
    required this.iconUrl,
    required this.title,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 350),
      child: CustomPaint(
        painter: SpeechBubblePainter(),
        child: Container(
          padding: EdgeInsets.only(bottom: 15, right: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                iconUrl,
                width: 52,
                height: 52,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.8,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupedMarker extends StatelessWidget {
  final int count;
  final double opacity;
  const GroupedMarker({super.key, required this.count, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    String eventWord;
    if (count >= 5 || count == 0) {
      eventWord = 'Событий';
    } else if (count >= 2 && count <= 4) {
      eventWord = 'События';
    } else {
      eventWord = 'Событие';
    }
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 350),
      child: CustomPaint(
        painter: SpeechBubblePainter(),
        child: Container(
          padding: EdgeInsets.only(bottom: 25, right: 25, left: 25, top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent),
                  // color: Colors.blueAccent,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 16.8,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text(
                eventWord,
                style: const TextStyle(
                  fontSize: 16.8,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 30.0;
    const tailHeight = 15.0; // длиннее хвост
    const tailWidth = 14.0; // уже хвост

    final bubbleHeight = size.height - tailHeight;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, bubbleHeight),
          const Radius.circular(radius),
        ),
      )
      // Начало хвоста
      ..moveTo(size.width / 2 - tailWidth / 2, bubbleHeight)
      ..lineTo(size.width / 2, size.height) // Острый конец
      ..lineTo(size.width / 2 + tailWidth / 2, bubbleHeight)
      ..close();

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawShadow(path,
        const Color.fromARGB(255, 153, 152, 152).withOpacity(0.15), 2, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ClusterMarker extends StatelessWidget {
  final List<String> iconUrls;
  final int count;

  const ClusterMarker({
    super.key,
    required this.iconUrls,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final iconsToShow = iconUrls.take(3).toList();
    return Stack(
      alignment: Alignment.center,
      children: [
        // Первый слой — иконки внахлёст
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(iconsToShow.length, (i) {
            return Transform.translate(
              offset: Offset(i * 18.0, 0), // сдвиг для оверлапа
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: CachedNetworkImage(
                  imageUrl: iconsToShow[i],
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
        ),
        // Если событий больше 3 — кружок с числом
        if (count > 3)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
