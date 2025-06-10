import 'dart:ui';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/alter_event_model.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/api/onbording/onbording_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/models/api_error.dart';
import 'package:acti_mobile/domain/models/auth_response.dart';
import 'package:acti_mobile/domain/models/social_login_response.dart';
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
  final storage = const FlutterSecureStorage();

  AuthBloc({required this.authRepository}) : super(ActiInitial()) {
    // AuthBloc() : super(ActiInitial()) {
    // final AuthRepository authRepository;
    on<ActiRegisterEvent>((event, emit) async {
      try {
        final normalizedphone = normalizePhone(event.phone);
        final tokenModel = await AuthApi().authRegister(normalizedphone);
        if (tokenModel != null) {
          await writeAuthTokens(
              tokenModel.accessToken, tokenModel.refreshToken);
          emit(ActiRegisteredState(phone: normalizedphone));
        }
      } catch (e) {
        emit(ActiRegisteredErrorState());
      }
    });

    on<SocialLoginRequested>((event, emit) async {
      if (state is AuthLoading) return;

      emit(AuthLoading());
      try {
        final response = await authRepository.socialLogin(event.request);

        if (response['access_token'] != null) {
          await writeAuthTokens(
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
            await AuthApi().authVerify(normalizePhone(event.phone), event.code);
        if (token != null) {
          await writeAuthTokens(
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
        if (isCreated != null) {
          emit(ActiCreatedActivityState());
        } else {
          emit(ActiCreatedActivityErrorState());
        }
      } catch (e) {
        emit(ActiCreatedActivityErrorState());
      }
    });

    on<ActiUpdateActivityEvent>((event, emit) async {
      try {
        final isUpdated = await EventsApi()
            .alterEvent(alterEvent: event.alterEventModel, isCreated: false);
        if (isUpdated != null) {
          emit(ActiUpdatedActivityState());
        } else {
          emit(ActiUpdatedActivityErrorState());
        }
      } catch (e) {
        emit(ActiUpdatedActivityErrorState());
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
