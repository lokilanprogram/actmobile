import 'package:flutter/material.dart';

class CategoryMarker extends StatelessWidget {
  final String iconUrl;
  final String title;

  const CategoryMarker({
    super.key,
    required this.iconUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpeechBubblePainter(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: 15,right: 15
        ),
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
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 30.0;
    const tailHeight = 15.0; // длиннее хвост
    const tailWidth = 14.0;  // уже хвост

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

    canvas.drawShadow(path, const Color.fromARGB(255, 153, 152, 152).withOpacity(0.15), 2, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
