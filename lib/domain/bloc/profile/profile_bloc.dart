import 'package:acti_mobile/data/models/profile_model.dart';
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
      if(profile != null){
        emit(ProfileGotState(profileModel: profile));
      }
      }catch(e){
        emit(ProfileGotErrorState());
      }
    });

    on<ProfileUpdateEvent>((event, emit) async{
      try{
        final profile = await ProfileApi().updateProfile(event.profileModel);
      if(profile != null){
        emit(ProfileUpdatedState(profileModel: profile));
      }
      }catch(e){
        emit(ProfileUpdatedErrorState());
      }
    });
  }
}
