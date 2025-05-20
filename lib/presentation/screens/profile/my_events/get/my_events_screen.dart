import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:acti_mobile/presentation/widgets/activity_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  bool isLoading = false;
  bool isVerified = false;
  ProfileEventModels? profileEventModels;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if(state is ProfileAcceptedUserOnActivityState){
          initialize();
        }
        if(state is ProfileCanceledActivityState){
          initialize();
        }
        if(state is ProfileGotListEventsState){
          setState(() {
            isLoading = false;
            isVerified = state.isVerified;
            profileEventModels = state.profileEventsModels;
          });
        }
          if(state is ProfileGotListEventsErrorState){
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(backgroundColor: Colors.white,
          appBar:isLoading?null: AppBarWidget(title: 'События',),
          extendBody: true,
          body: isLoading
              ? LoaderWidget()
              : Stack(
                children: [
                  Positioned.fill(
                    child: SafeArea(
                        child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: ListView(
                          children: [
                            TabBarWidget(),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    hintText: 'Поиск',
                                    hintStyle: TextStyle(
                                        fontFamily: 'Gilroy',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                           profileEventModels!= null? Column(
                            children: profileEventModels!.events.map((event){
                              return MyCardEventWidget(
                                isPublicUser: false,
                                organizedEvent: event,
                              );
                            }).toList(),
                           ):Container()
                          ],
                        ),
                      )),
                  ),
                  Align(alignment: Alignment.bottomCenter,
                    child: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                                child: Container(decoration: BoxDecoration(color: Colors.transparent),
                                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ActivityBarWidget(isVerified: isVerified),
                        SizedBox(height: 15,),
                      CustomNavBarWidget(selectedIndex: 4, onTabSelected: (index){
                        if(index == 0){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> 
                          MapScreen()));
                        }
                      }),
                    ],
                                    ),
                                ),),
                  ),
                ],
              )),
    );
  }
}

