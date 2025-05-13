import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  bool isLoading = false;
  late ProfileEventModels profileEventModels;
  late ProfileModel profileModel;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if(state is ProfileGotListEventsState){
          setState(() {
            profileEventModels = state.profileEventsModels;
            context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
          });
        }
        if(state is ProfileGotState){
          setState(() {
            isLoading = false;
            profileModel = state.profileModel;
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
          appBar: AppBarWidget(title: 'События',),
          bottomNavigationBar:
          Padding(
            padding: EdgeInsets.only(bottom: 60,right: 30,left: 30),
            child: SizedBox(height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: (){
                      profileModel.isEmailVerified ?  Navigator.push(context, MaterialPageRoute(builder: (context)=>
                        CreateEventScreen())): 
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Проверьте почту и перейдите по ссылке для активации'),
                        backgroundColor: Colors.green,));
                      },
                      child: Material(
                        elevation: 1.2,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(  height: 59,
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(98, 207, 102, 1),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                      SvgPicture.asset('assets/icons/icon_add.svg'),
                                      SizedBox(width: 10,),
                                      Text('Создать активность',style: TextStyle(color: Colors.white,
                                      fontFamily: 'Gilroy',fontSize: 17,fontWeight: FontWeight.bold),)
                                    ],),
                          
                          
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                  CustomNavBar(selectedIndex: 4, onTabSelected: (index){
                    if(index == 0){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> 
                      MapScreen()));
                    }
                  }),
                ],
              ),
            )),
          body: isLoading
              ? LoaderWidget()
              : SafeArea(
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
                      ListView.builder(
                        shrinkWrap: true,
                        primary: true,
                        itemCount: profileEventModels.events.length,
                        itemBuilder: 
                      (context,index){
                        return MyCardEventWidget(
                          profileEventModel: profileEventModels.events[index],
                        );
                      })
                    ],
                  ),
                ))),
    );
  }
}

