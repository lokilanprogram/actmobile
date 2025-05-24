import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
Future renderMarkerToImage(GlobalKey key) async {
  RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  final result =  byteData!.buffer.asUint8List();
  return result;
}

class CustomMarkerWidget extends StatelessWidget {
  final String text;
  final String iconUrl;

  const CustomMarkerWidget({
    super.key,
    required this.text,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(iconUrl, width: 20, height: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
