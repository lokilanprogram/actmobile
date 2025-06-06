import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';

Widget buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF4A8EFF),width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: mainBlueColor, fontSize: 11, fontFamily: 'Inter'),
      ),
    );
  }

  Widget buildInterestExpandedChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Color(0xFF4A8EFF), width: 1.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Text(
        label,
        overflow: TextOverflow.fade,
        maxLines: 1,
        style: const TextStyle(
            color: Color(0xFF4A8EFF), fontSize: 11, fontFamily: 'Inter'),
      ),
    ),
  );
}

List<List<T>> chunkList<T>(List<T> list, int size) {
  List<List<T>> chunks = [];
  for (var i = 0; i < list.length; i += size) {
    chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
  }
  return chunks;
}

Widget buildInterestsGrid(List<String> categories) {
  final chunks = chunkList(categories, 3);

  return Column(
    children: chunks.map((chunk) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            for (int i = 0; i < chunk.length; i++) ...[
              Expanded(child: buildInterestExpandedChip(chunk[i])),
              if (i != chunk.length - 1) const SizedBox(width: 8), // отступ между
            ],
          ],
        ),
      );
    }).toList(),
  );
}
