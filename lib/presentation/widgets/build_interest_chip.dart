import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';

Widget buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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