import 'dart:ui';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/alter_event_model.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/data/models/token_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/api/onbording/onbording_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/models/api_error.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/models/auth_response.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/models/social_login_response.dart';
import 'package:acti_mobile/domain/repositories/auth_repository.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  String? _savedEventId;
  final storage = SecureStorageService();

  AuthBloc({required this.authRepository}) : super(ActiInitial()) {
    // AuthBloc() : super(ActiInitial()) {
    // final AuthRepository authRepository;
    on<ActiRegisterEvent>((event, emit) async {
      try {
        final normalizedphone = normalizePhone(event.phone);
        final loginModel = await AuthApi().authLogin(normalizedphone);

        final tokenModel = TokenModel(
            tokenType: "tokenType",
            accessToken: "accessToken",
            refreshToken: "refreshToken");

        if (loginModel != null) {
          await storage.writeTokens(
              tokenModel.accessToken, tokenModel.refreshToken);
          emit(AuthReqIdState(loginModel: loginModel, phone: normalizedphone));
        }
      } catch (e) {
        emit(ActiRegisteredErrorState());
      }
    });

    on<ActiAuthStatusEvent>((event, emit) async {
      try {
        final status = await AuthApi().authStatus(event.authReqId);
        if (status != null && status.status == "authenticated") {
          final tokenModel = await AuthApi()
              .authRegister(status.authReqId, status.registerToken);
          if (tokenModel != null) {
            await storage.writeTokens(
                tokenModel.accessToken, tokenModel.refreshToken);
            emit(ActiRegisteredState(phone: status.phone));
          }
        } else if (status != null && status.status == "rejected") {
          emit(ActiRejectedState());
        } else if (status != null && status.status == "sms_sent") {
          emit(ActiSmsSentState());
        }
      } catch (e) {
        emit(AuthReqIdErrorState());
      }
    });

    on<SocialLoginRequested>((event, emit) async {
      print('🔥 SocialLoginRequested получен в AuthBloc');
      print('🔥 Тип запроса: ${event.request.runtimeType}');
      developer.log('🔥 SocialLoginRequested получен в AuthBloc',
          name: 'AUTH_BLOC');
      developer.log('🔥 Тип запроса: ${event.request.runtimeType}',
          name: 'AUTH_BLOC');

      if (state is AuthLoading) return;

      emit(AuthLoading());
      try {
        print('🔥 Отправляем запрос в authRepository.socialLogin');
        developer.log('🔥 Отправляем запрос в authRepository.socialLogin',
            name: 'AUTH_BLOC');

        final response = await authRepository.socialLogin(event.request);

        if (response['access_token'] != null) {
          await storage.writeTokens(
            response['access_token'],
            response['refresh_token'],
          );

          // Эмитим ActiRegisteredState для унификации с процессом регистрации через телефон
          emit(ActiRegisteredState(phone: ''));

          // Добавляем навигацию на InitialScreen
          await Future.delayed(Duration(seconds: 1));
          Navigator.pushAndRemoveUntil(
            event.context,
            MaterialPageRoute(builder: (_) => InitialScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          emit(SocialAuthSuccess(SocialLoginResponse.fromJson(response)));
        }
      } on DioException catch (e) {
        developer.log('DioException при социальной авторизации: ${e.message}',
            name: 'AUTH_BLOC');
        final errorMessage = e.response?.data['detail'] ??
            e.message ??
            'Ошибка при социальной авторизации';
        emit(AuthFailure(errorMessage));
      } on ApiError catch (e) {
        developer.log('ApiError при социальной авторизации: ${e.detail}',
            name: 'AUTH_BLOC');
        emit(AuthFailure(e.detail.first.msg));
      } catch (e) {
        developer.log('Неизвестная ошибка при социальной авторизации: $e',
            name: 'AUTH_BLOC');
        emit(AuthFailure('Произошла ошибка при социальной авторизации'));
      }
    });

    // on<SocialLoginRequested>((event, emit) async {
    //   if (state is AuthLoading) return;

    //   emit(AuthLoading());
    //   try {
    //     final response = await authRepository.socialLogin(event.request);

    //     if (response['access_token'] != null) {
    //       emit(AuthSuccess(TokenResponse.fromJson(response), null));
    //     } else {
    //       emit(SocialAuthSuccess(SocialLoginResponse.fromJson(response)));
    //     }
    //   } on DioException catch (e) {
    //     developer.log('DioException при социальной авторизации: ${e.message}',
    //         name: 'AUTH_BLOC');
    //     final errorMessage = e.response?.data['detail'] ??
    //         e.message ??
    //         'Ошибка при социальной авторизации';
    //     emit(AuthFailure(errorMessage));
    //   } on ApiError catch (e) {
    //     developer.log('ApiError при социальной авторизации: ${e.detail}',
    //         name: 'AUTH_BLOC');
    //     emit(AuthFailure(e.detail.first.msg));
    //   } catch (e) {
    //     developer.log('Неизвестная ошибка при социальной авторизации: $e',
    //         name: 'AUTH_BLOC');
    //     emit(AuthFailure('Произошла ошибка при социальной авторизации'));
    //   }
    // });

    on<ActiGetOnbordingEvent>((event, emit) async {
      try {
        final onbording = await OnbordingApi().getOnbording();
        if (onbording != null) {
          print(onbording.toString());
          emit(ActiGotOnbordingState(listOnbordingModel: onbording));
        }
      } catch (e) {
        emit(ActiGotOnbordingErrorState());
      }
    });
    on<ActiSaveOnbordingEvent>((event, emit) async {
      try {
        final listId = event.listOnboarding.map((event) => event.id).toList();
        final isSaved = await OnbordingApi().saveOnbording(listId);
        if (isSaved) {
          print('saved categories');
          emit(ActiSavedOnbordingState());
        }
      } catch (e) {
        emit(ActiSavedOnbordingErrorState());
      }
    });

    on<ActiVerifyEvent>((event, emit) async {
      try {
        final token =
            await AuthApi().authVerify(normalizePhone(event.phone), event.code, event.authReqId);
        if (token != null) {
          await storage.writeTokens(
            token.accessToken,
            token.refreshToken,
          );
          print(token.toString());
          emit(ActiVerifiedState());
        }
      } catch (e) {
        emit(ActiVerifiedErrorState());
      }
    });

    on<ActiCreateActivityEvent>((event, emit) async {
      try {
        final isCreated = await EventsApi()
            .alterEvent(alterEvent: event.createEventModel, isCreated: true);
        isCreated.fold((l) => emit(ActiUpdatedActivityErrorState(message: l)),
            (r) => emit(ActiCreatedActivityState()));
      } catch (e) {
        emit(ActiUpdatedActivityErrorState(message: e.toString()));
      }
    });

    on<ActiUpdateActivityEvent>((event, emit) async {
      try {
        final isUpdated = await EventsApi()
            .alterEvent(alterEvent: event.alterEventModel, isCreated: false);

        isUpdated.fold((l) => emit(ActiUpdatedActivityErrorState(message: l)),
            (r) => emit(ActiUpdatedActivityState()));
      } catch (e) {
        emit(ActiUpdatedActivityErrorState(message: e.toString()));
      }
    });

    on<AuthDeleteAccountEvent>((event, emit) async {
      try {
        final isDeleted = await AuthApi().authDelete();
        if (isDeleted) {
          await authRepository.logout(); // Очищаем локальные токены
          emit(AuthAccountDeletedState());
        } else {
          emit(AuthFailure('Не удалось удалить аккаунт.'));
        }
      } catch (e) {
        developer.log('Ошибка при удалении аккаунта: $e', name: 'AUTH_BLOC');
        emit(AuthFailure('Произошла ошибка при удалении аккаунта: $e'));
      }
    });
  }
}
