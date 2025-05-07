import 'package:acti_mobile/data/models/auth_codes.dart';
import 'package:acti_mobile/domain/api/acti_api.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'acti_event.dart';
part 'acti_state.dart';

class ActiBloc extends Bloc<ActiEvent, ActiState> {
  ActiBloc() : super(ActiInitial()) {
    on<ActiRegisterEvent>((event, emit)async {
      final authCodes = await ActiApi().authRegister(event.phone);
      if(authCodes!=null){
        print(authCodes.toString());
        emit(ActiRegisteredState(authCodes: authCodes));
      }else{
        emit(ActiRegisteredErrorState());
      }
    });
  }
}
