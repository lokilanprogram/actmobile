import 'package:acti_mobile/presentation/widgets/rotating_icon.dart';
import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: RotatingIcon());
  }
}