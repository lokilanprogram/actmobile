import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget small;
  final Widget big;

  const Responsive({
    super.key,
    required this.small,
    required this.big,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.width >= 400) {
      return big;
    } else {
      return small;
    }
  }
}