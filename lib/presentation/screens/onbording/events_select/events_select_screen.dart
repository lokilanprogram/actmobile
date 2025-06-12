import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_start/events_start_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/widgets/pop_nav_button.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EventsSelectScreen extends StatefulWidget {
  final bool fromUpdate;
  const EventsSelectScreen({super.key, required this.fromUpdate});

  @override
  State<EventsSelectScreen> createState() => _EventsSelectScreenState();
}

class _EventsSelectScreenState extends State<EventsSelectScreen> {
  bool isLoading = false;
  late ListOnbordingModel listOnbordingModel;
  List<EventOnboarding> listOnboarding = [];
  late List<bool> selected;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context.read<AuthBloc>().add(ActiGetOnbordingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ActiSavedOnbordingState) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EventsStartScreen()));
        }
        if (state is ActiSavedOnbordingErrorState) {
          setState(() {
            isLoading = false;
          });
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
        if (state is ActiGotOnbordingState) {
          setState(() {
            isLoading = false;
            listOnbordingModel = state.listOnbordingModel;
            selected =
                List<bool>.filled(listOnbordingModel.categories.length, false);
          });
        }
        if (state is ActiGotOnbordingErrorState) {
          setState(() {
            isLoading = false;
          });
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: isLoading
              ? LoaderWidget()
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/back.png",
                      ),
                      fit: BoxFit.cover,
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
                        SizedBox(
                          height: 15,
                        ),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 4,
                          children: List.generate(
                              listOnbordingModel.categories.length, (index) {
                            final event = listOnbordingModel.categories[index];
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
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color:
                                      isSelected ? Colors.blue : Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
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
                        // SizedBox(
                        //   height: 45,
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                          ),
                          child: Center(
                              child: SvgPicture.asset(
                            'assets/texts/text_select_event.svg',
                            fit: BoxFit.fill,
                          )),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PopNavButton(
                              text: 'Назад',
                              function: () {
                                Navigator.pop(context);
                              },
                            ),
                            PopNavButton(
                              text: widget.fromUpdate
                                  ? 'Сохранить'
                                  : (listOnboarding.isNotEmpty
                                      ? 'Сохранить'
                                      : 'Выбирите категории'),
                              function: widget.fromUpdate
                                  ? () {
                                      Navigator.pop(context, listOnboarding);
                                    }
                                  : () {
                                      if (listOnboarding.isEmpty) {
                                        showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.info(
                                            message:
                                                "Для продолжения необходимо выбрать хотя бы одну категорию",
                                            backgroundColor: Color.fromARGB(
                                                255, 66, 147, 239),
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                          displayDuration:
                                              const Duration(seconds: 3),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        isLoading = true;
                                      });
                                      context.read<AuthBloc>().add(
                                          ActiSaveOnbordingEvent(
                                              listOnboarding: listOnboarding));
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                )),
    );
  }
}
