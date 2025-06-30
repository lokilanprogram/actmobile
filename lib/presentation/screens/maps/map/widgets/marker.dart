import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

class CategoryMarker extends StatelessWidget {
  final String iconUrl;
  final String title;
  final double opacity;
  final VoidCallback? onTap;

  const CategoryMarker({
    super.key,
    required this.iconUrl,
    required this.title,
    this.opacity = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: const _OptimizedSpeechBubblePainter(),
          child: Container(
            padding: const EdgeInsets.only(bottom: 15, right: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: iconUrl,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  // placeholder: (context, url) => Container(
                  //   width: 30,
                  //   height: 30,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[200],
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   child: const Icon(Icons.category,
                  //       color: Colors.grey, size: 16),
                  // ),
                  errorWidget: (context, url, error) => Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        const Icon(Icons.error, color: Colors.grey, size: 16),
                  ),
                  memCacheWidth: 60, // 2x для retina
                  memCacheHeight: 60,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GroupedMarker extends StatelessWidget {
  final int count;
  final double opacity;
  final VoidCallback? onTap;
  const GroupedMarker(
      {super.key, required this.count, this.opacity = 1.0, this.onTap});

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
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: const _OptimizedSpeechBubblePainter(),
          child: Container(
            padding:
                const EdgeInsets.only(bottom: 25, right: 25, left: 25, top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    eventWord,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
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

class CircleCountMarker extends StatelessWidget {
  final int count;
  const CircleCountMarker({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

// Оптимизированный CustomPainter с кэшированием
class _OptimizedSpeechBubblePainter extends CustomPainter {
  const _OptimizedSpeechBubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 30.0;
    const tailHeight = 15.0;
    const tailWidth = 14.0;

    final bubbleHeight = size.height - tailHeight;

    // Создаем путь только один раз
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, bubbleHeight),
          const Radius.circular(radius),
        ),
      )
      ..moveTo(size.width / 2 - tailWidth / 2, bubbleHeight)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + tailWidth / 2, bubbleHeight)
      ..close();

    // Кэшируем краски
    final shadowPaint = Paint()
      ..color = const Color.fromARGB(
          38, 153, 152, 152) // Предвычисленная прозрачность
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Рисуем тень и заливку
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Оптимизированная версия CategoryMarker с предзагруженным изображением
class OptimizedCategoryMarker extends StatelessWidget {
  final Uint8List? preloadedImage;
  final String title;
  final double opacity;
  final VoidCallback? onTap;

  const OptimizedCategoryMarker({
    super.key,
    this.preloadedImage,
    required this.title,
    this.opacity = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: const _OptimizedSpeechBubblePainter(),
          child: Container(
            padding: const EdgeInsets.only(bottom: 15, right: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(6),
                    // border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: preloadedImage != null
                        ? Image.memory(
                            preloadedImage!,
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          )
                        : Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.category,
                                color: Colors.grey, size: 16),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
