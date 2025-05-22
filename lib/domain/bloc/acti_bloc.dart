import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/create_event_model.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/api/onbording/onbording_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'acti_event.dart';
part 'acti_state.dart';

class ActiBloc extends Bloc<ActiEvent, ActiState> {
  final storage = const FlutterSecureStorage();
  ActiBloc() : super(ActiInitial()) {
    on<ActiRegisterEvent>((event, emit)async {
      try{
        final normalizedphone = normalizePhone(event.phone);
      final isRegistered = await AuthApi().authRegister(normalizedphone);
      if(isRegistered){
        print(isRegistered.toString());
        emit(ActiRegisteredState(phone: normalizedphone));
      }
      }catch(e){
        emit(ActiRegisteredErrorState());
      }
    });

  
    on<ActiGetOnbordingEvent>((event, emit)async {
      try{
      final onbording = await OnbordingApi().getOnbording();
      if(onbording!=null){
        print(onbording.toString());
        emit(ActiGotOnbordingState(listOnbordingModel: onbording));
      }
      }catch(e){
        emit(ActiGotOnbordingErrorState());
      }
    });
    on<ActiSaveOnbordingEvent>((event, emit)async {
      try{
      final listId = event.listOnboarding.map((event)=>event.id).toList();
      final isSaved = await OnbordingApi().saveOnbording(listId);
      if(isSaved){
        print('saved categories');
        emit(ActiSavedOnbordingState());
      }
      }catch(e){
        emit(ActiSavedOnbordingErrorState());
      }
    });

    on<ActiVerifyEvent>((event, emit)async {
      try{
        final token = await AuthApi().authVerify(normalizePhone(event.phone), event.code);
      if(token!=null){
        await writeAuthTokens(token.accessToken, token.refreshToken);
        print(token.toString());
        emit(ActiVerifiedState());
      }
      }catch(e){
        emit(ActiVerifiedErrorState());
      }
    });

        on<ActiCreateActivityEvent>((event, emit)async {
      try{
        final isCreated = await EventsApi().alterEvent(alterEvent: event.createEventModel,isCreated: true);
        if(isCreated!=null){
        emit(ActiCreatedActivityState());
        }else{
        emit(ActiCreatedActivityErrorState());
        }
      }catch(e){
        emit(ActiCreatedActivityErrorState());
      }
    });


    on<ActiUpdateActivityEvent>((event, emit)async {
      try{
        final isUpdated = await EventsApi().alterEvent(alterEvent: event.alterEventModel, isCreated: false);
        if(isUpdated!=null){
        emit(ActiUpdatedActivityState());
        }else{
        emit(ActiUpdatedActivityErrorState());
        }
      }catch(e){
        emit(ActiUpdatedActivityErrorState());
      }
    });
  }
}
