import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.profileModel,
  });

  final ProfileModel profileModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 10;
        final int columns = 3;
        final double itemWidth =
            (constraints.maxWidth -
                    spacing * (columns - 1)) /
                columns;
    
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: profileModel.categories
              .map((event) => SizedBox(
                    width: itemWidth,
                    child: buildInterestChip(
                        event.name),
                  ))
              .toList(),
        );
      },
    );
  }
}