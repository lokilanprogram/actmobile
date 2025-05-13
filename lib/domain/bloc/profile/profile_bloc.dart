import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileGetEvent>((event, emit) async{
      try{
        final profile = await ProfileApi().getProfile();
        final users = await ProfileApi().getSimiliarUsers(); 
      if(profile != null && users != null){
        emit(ProfileGotState(profileModel: profile,similiarUsersModel: users));
      }
      }catch(e){
        emit(ProfileGotErrorState());
      }
    });

    on<ProfileUpdateEvent>((event, emit) async{
      try{
        final profile = await ProfileApi().updateProfile(event.profileModel);
        if(event.profileModel.photoUrl!= null){
          await ProfileApi().updateProfilePicture(event.profileModel.photoUrl!);
        }
      final updatedProfile = await ProfileApi().getProfile();
      if(profile != null && updatedProfile != null ){
        emit(ProfileUpdatedState(profileModel: updatedProfile));
      }
      }catch(e){
        emit(ProfileUpdatedErrorState());
      }
    });

     on<ProfileGetListEventsEvent>((event, emit) async{
      try{
        final events = await ProfileApi().getProfileListEvents();
      if(events != null ){
        emit(ProfileGotListEventsState(profileEventsModels: events));
      }
      }catch(e){
        emit(ProfileGotListEventsErrorState());
      }
    });


    on<ProfileGetEventDetailEvent>((event, emit) async{
      try{
        final eventDetail = await ProfileApi().getProfileEvent(event.eventId);
      if(eventDetail != null ){
        emit(ProfileGotEventDetailState(eventModel: eventDetail));
      }
      }catch(e){
        emit(ProfileGotEventDetailErrorState());
      }
      
    });
  }
}
