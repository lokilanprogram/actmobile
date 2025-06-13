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

  const EventsSelectScreen({
    super.key,
    required this.fromUpdate,
    required this.categories,
    this.onCategoriesSelected,
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
    selected = List<bool>.filled(widget.categories.length, false);
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
            right: 35,
            left: 35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Image.network(
                              event.iconPath,
                              width: 18,
                              height: 18,
                              color: isSelected ? Colors.white : null,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                event.name,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 15,
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
                padding: const EdgeInsets.only(top: 30, right: 10),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/texts/text_select_event.svg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
