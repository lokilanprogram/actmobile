import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/onbording/widgets/pop_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EventsSelectScreen extends StatefulWidget {
  final bool fromUpdate;
  final Function(List<EventOnboarding>)? onCategoriesSelected;
  final List<EventOnboarding> categories;
  final List<EventOnboarding> selectedCategories;

  const EventsSelectScreen({
    super.key,
    required this.fromUpdate,
    required this.categories,
    this.onCategoriesSelected,
    this.selectedCategories = const [],
  });

  @override
  State<EventsSelectScreen> createState() => _EventsSelectScreenState();
}

class _EventsSelectScreenState extends State<EventsSelectScreen> {
  List<EventOnboarding> listOnboarding = [];
  late List<bool> selected;

  @override
  void initState() {
    super.initState();
    selected = List<bool>.generate(
        widget.categories.length,
        (index) =>
            widget.selectedCategories.contains(widget.categories[index]));
    listOnboarding = List<EventOnboarding>.from(widget.selectedCategories);
  }

  @override
  void didUpdateWidget(covariant EventsSelectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategories != oldWidget.selectedCategories) {
      selected = List<bool>.generate(
          widget.categories.length,
          (index) =>
              widget.selectedCategories.contains(widget.categories[index]));
      listOnboarding = List<EventOnboarding>.from(widget.selectedCategories);
      setState(() {});
    }
  }

  Widget _buildShimmerGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 4,
      children: List.generate(20, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2F7),
              Color.fromARGB(255, 66, 147, 239),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            right: width * 0.09,
            left: width * 0.09,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.02),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: height * 0.01,
                crossAxisSpacing: width * 0.03,
                childAspectRatio: 4,
                children: List.generate(widget.categories.length, (index) {
                  final event = widget.categories[index];
                  final isSelected = selected[index];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selected[index] = !selected[index];
                        if (selected[index]) {
                          listOnboarding.add(event);
                        } else {
                          listOnboarding.remove(event);
                        }
                        widget.onCategoriesSelected?.call(listOnboarding);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: isSelected ? Colors.blue : Colors.white,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: width * 0.025),
                        child: Row(
                          children: [
                            Image.network(
                              event.iconPath,
                              width: width * 0.045,
                              height: width * 0.045,
                              color: isSelected ? Colors.white : null,
                            ),
                            SizedBox(width: width * 0.012),
                            Expanded(
                              child: Text(
                                event.name,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.05, left: width * 0),
                child: SvgPicture.asset(
                  'assets/texts/text_select_event.svg',
                  fit: BoxFit.fill,
                  width: width * 0.7,
                ),
              ),
              // SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
