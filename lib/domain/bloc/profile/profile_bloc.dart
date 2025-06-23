import 'dart:convert';
import 'dart:developer' as developer;

import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/public_user_model.dart';
import 'package:acti_mobile/data/models/recommendated_user_model.dart';
import 'package:acti_mobile/data/models/reviews_model.dart';
import 'package:acti_mobile/data/models/searched_events_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final storage = SecureStorageService();

  int _eventOffset = 0;
  int _visitedEventOffset = 0;
  final int _pageLimit = 10;

  ProfileBloc() : super(ProfileInitial()) {
    on<InitializeMapEvent>((event, emit) async {
      try {
        final events = await EventsApi()
            .searchEventsOnMap(event.latitude, event.longitude);
        if (events != null) {
          emit(InitializeMapState(searchedEventsModel: events));
        }
      } catch (e) {
        emit(InitializeMapErrorState());
      }
    });
    on<SearchEventsOnMapEvent>((event, emit) async {
      try {
        final events = await EventsApi().searchEventsOnMap(
            event.latitude, event.longitude,
            filters: event.filters);
        if (events != null) {
          emit(SearchedEventsOnMapState(searchedEventsModel: events));
        }
      } catch (e) {
        emit(SearchedEventsOnMapErrorState());
      }
    });
    on<ProfileGetEvent>((event, emit) async {
      try {
        final profile = await ProfileApi().getProfile();
        if (profile != null) {
          if (profile.status == 'blocked') {
            emit(ProfileBlockedAdminState(profileModel: profile));
          } else if (profile.status == 'deleted') {
            emit(ProfileDeleteAdminState(profileModel: profile));
          } else {
            final users = await ProfileApi().getSimiliarUsers();
            if (users != null) {
              emit(ProfileGotState(
                  profileModel: profile, similiarUsersModel: users));
            }
          }
        }
      } catch (e) {
        emit(ProfileGotErrorState());
      }
    });

    on<ProfileResendEmailEvent>((event, emit) async {
      try {
        final profile = await ProfileApi().getProfile();
        if (profile != null) {
          if (profile.isProfileCompleted == true) {
            final isSend = await ProfileApi().postResendEmail();
            isSend.fold(
              (l) => emit(ProfileResendEmailErrorState(message: l)),
              (r) => emit(ProfileResendEmailState()),
            );
          } else {
            emit(ProfileResendEmailErrorState(
                message: "Заполните данные профиля"));
          }
        }
      } catch (e) {
        emit(ProfileResendEmailErrorState(message: e.toString()));
      }
    });

    on<ProfileGetPublicUserEvent>((event, emit) async {
      try {
        final user = await ProfileApi().getPublicUser(event.userId);
        final blockedUser = await ProfileApi().getBlockedUser(event.userId);
        user.fold((l) {
          emit(ProfileGotPublicUserState(
              publicUserModel: l, isBlocked: blockedUser));
        }, (r) {
          emit(ProfileGotPublicUserErrorState(message: r.toString()));
        });
      } catch (e) {
        emit(ProfileGotPublicUserErrorState(message: e.toString()));
      }
    });

    on<ProfileUnblockUserEvent>((event, emit) async {
      try {
        final isUnblocked = await ProfileApi().unblockUser(event.userId);
        if (isUnblocked != null) {
          emit(ProfileUnblockedUserState());
        }
      } catch (e) {
        emit(ProfileUnblockedUserErrorState());
      }
    });

    on<ProfileJoinEvent>((event, emit) async {
      try {
        final isJoined = await EventsApi().joinEvent(event.eventId);
        final eventModel = await EventsApi().getProfileEvent(event.eventId);
        if (isJoined != null) {
          emit(ProfileJoinedState(eventModel: eventModel!));
        }
      } on Exception catch (e) {
        final jsonStr = e.toString().replaceFirst('Error: ', '');
        // Удаляем префикс "Exception: "
        String cleanJson = jsonStr.replaceFirst('Exception: ', '');

        // Парсим строку как JSON
        Map<String, dynamic> data = json.decode(cleanJson);

        // Достаём значение по ключу "detail"
        String detail = data['detail'];
        emit(ProfileJoinedErrorState(errorText: detail));
      }
    });

    on<ProfileLeaveEvent>((event, emit) async {
      try {
        final isLeft = await EventsApi().leaveEvent(event.eventId);
        if (isLeft != null) {
          final eventModel = await EventsApi().getProfileEvent(event.eventId);
          emit(ProfileLeftState(eventModel: eventModel!));
        }
      } on Exception catch (e) {
        final jsonStr = e.toString().replaceFirst('Error: ', '');
        // Удаляем префикс "Exception: "
        String cleanJson = jsonStr.replaceFirst('Exception: ', '');

        // Парсим строку как JSON
        Map<String, dynamic> data = json.decode(cleanJson);

        // Достаём значение по ключу "detail"
        String detail = data['detail'];
        emit(ProfileLeftErrorState(errorText: detail));
      }
    });

    on<ProfileReportEvent>((event, emit) async {
      try {
        final isReported = await EventsApi().reportEvent(
            event.imageUrl, event.title, event.comment, event.eventId);
        if (isReported != null) {
          emit(ProfileReportedEventState());
        }
      } on Exception catch (e) {
        final jsonStr = e.toString().replaceFirst('Error: ', '');
        // Удаляем префикс "Exception: "
        String cleanJson = jsonStr.replaceFirst('Exception: ', '');

        // Парсим строку как JSON
        Map<String, dynamic> data = json.decode(cleanJson);

        // Достаём значение по ключу "detail"
        String detail = data['detail'];
        emit(ProfileReportedEventErrorState(errorText: detail));
      }
    });
    on<ProfileUpdateEvent>((event, emit) async {
      try {
        developer.log(
          '=== Начало обновления профиля ===\n'
          'Отправляемые данные:\n'
          'ID: ${event.profileModel.id}\n'
          'Имя: ${event.profileModel.name}\n'
          'Фамилия: ${event.profileModel.surname}\n'
          'Email: ${event.profileModel.email}\n'
          'Город: ${event.profileModel.city}\n'
          'О себе: ${event.profileModel.bio}\n'
          'Организация: ${event.profileModel.isOrganization}\n'
          'Категории: ${event.profileModel.categories.map((e) => e.name).toList()}\n'
          'Скрыть мои мероприятия: ${event.profileModel.hideMyEvents}\n'
          'Скрыть посещенные мероприятия: ${event.profileModel.hideAttendedEvents}',
          name: 'ProfileBloc',
        );

        final postProfile = await ProfileApi().updateProfile(
          event.profileModel,
        );

        late final ProfileModel profile;

        postProfile.fold(
            (l) => emit(ProfileUpdatedErrorState(errorMessage: l)),
            (r) => profile = r);

        if (postProfile.isRight()) {
          developer.log(
            '=== Ответ сервера на обновление профиля ===\n'
            'Статус: Успешно\n'
            'Обновленные данные профиля:\n'
            'ID: ${profile.id}\n'
            'Имя: ${profile.name}\n'
            'Фамилия: ${profile.surname}\n'
            'Email: ${profile.email}\n'
            'Город: ${profile.city}\n'
            'О себе: ${profile.bio}\n'
            'Организация: ${profile.isOrganization}\n'
            'Категории: ${profile.categories.map((e) => e.name).toList()}\n'
            'Скрыть мои мероприятия: ${profile.hideMyEvents}\n'
            'Скрыть посещенные мероприятия: ${profile.hideAttendedEvents}',
            name: 'ProfileBloc',
          );

          String? photoError;
          if (event.profileModel.photoUrl != null) {
            try {
              developer.log(
                '=== Обновление фотографии профиля ===\n'
                'Путь к файлу: ${event.profileModel.photoUrl}',
                name: 'ProfileBloc',
              );
              await ProfileApi()
                  .updateProfilePicture(event.profileModel.photoUrl!);
              developer.log('Фотография успешно обновлена',
                  name: 'ProfileBloc');
            } catch (e) {
              developer.log(
                '=== Ошибка при обновлении фотографии ===\n'
                'Тип ошибки: ${e.runtimeType}\n'
                'Сообщение: $e',
                name: 'ProfileBloc',
                error: e,
              );
              photoError = e.toString().replaceAll('Exception: ', '');
            }
          }

          // Получаем обновленные данные профиля
          final updatedProfile = await ProfileApi().getProfile();
          // Получаем обновленный список похожих пользователей
          final similarUsers = await ProfileApi().getSimiliarUsers();

          if (updatedProfile != null && similarUsers != null) {
            developer.log(
              '=== Финальное состояние профиля ===\n'
              'ID: ${updatedProfile.id}\n'
              'Имя: ${updatedProfile.name}\n'
              'Фамилия: ${updatedProfile.surname}\n'
              'Email: ${updatedProfile.email}\n'
              'Город: ${updatedProfile.city}\n'
              'О себе: ${updatedProfile.bio}\n'
              'Организация: ${updatedProfile.isOrganization}\n'
              'Категории: ${updatedProfile.categories.map((e) => e.name).toList()}\n'
              'Скрыть мои мероприятия: ${updatedProfile.hideMyEvents}\n'
              'Скрыть посещенные мероприятия: ${updatedProfile.hideAttendedEvents}\n'
              'URL фото: ${updatedProfile.photoUrl}\n'
              '=== Обновление профиля завершено ===',
              name: 'ProfileBloc',
            );

            if (photoError != null) {
              emit(ProfileUpdatedWithPhotoErrorState(
                profileModel: updatedProfile,
                photoError: photoError,
              ));
            } else {
              emit(ProfileUpdatedState(profileModel: updatedProfile));
            }

            // Обновляем данные на обоих экранах
            emit(ProfileGotState(
              profileModel: updatedProfile,
              similiarUsersModel: similarUsers,
            ));
          }
        }
      } catch (e) {
        developer.log(
          '=== Ошибка при обновлении профиля ===\n'
          'Тип ошибки: ${e.runtimeType}\n'
          'Сообщение об ошибке: $e',
          name: 'ProfileBloc',
          error: e,
        );
        String errorMessage = 'Произошла ошибка при обновлении профиля';

        if (e.toString().contains('Connection refused')) {
          errorMessage =
              'Нет подключения к серверу. Проверьте интернет-соединение';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Превышено время ожидания ответа от сервера';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Сессия истекла. Пожалуйста, войдите снова';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Нет прав для выполнения операции';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Ошибка на сервере. Попробуйте позже';
        }

        emit(ProfileUpdatedErrorState(errorMessage: errorMessage));
      }
    });

    on<ProfileGetListEventsEvent>((event, emit) async {
      try {
        final currentState = state;
        List<OrganizedEventModel> allEvents = [];
        List<OrganizedEventModel> allVisitedEvents = [];

        if (event.loadMoreMy && currentState is ProfileGotListEventsState) {
          allEvents = List.from(currentState.profileEventsModels!.events);
        }
        if (event.loadMoreVisited &&
            currentState is ProfileGotListEventsState) {
          allVisitedEvents =
              List.from(currentState.profileVisitedEventsModels!.events);
        }
        if (!event.loadMoreVisited && !event.loadMoreMy) {
          _eventOffset = 0;
          _visitedEventOffset = 0;
        }

        final profile = await ProfileApi().getProfile();

        final events = await ProfileApi()
            .getProfileListEvents(offset: _eventOffset, limit: _pageLimit);
        final visitedEvents = await ProfileApi().getProfileVisitedListEvents(
            offset: _visitedEventOffset, limit: _pageLimit);

        if (events != null) {
          allEvents.addAll(events.events);
          //allEvents.sort((a, b) => a.dateStart.compareTo(b.dateStart));
          _eventOffset += events.events.length;
        }

        if (visitedEvents != null) {
          allVisitedEvents.addAll(visitedEvents.events);
          //allVisitedEvents.sort((a, b) => a.dateStart.compareTo(b.dateStart));
          _visitedEventOffset += visitedEvents.events.length;
        }

        emit(ProfileGotListEventsState(
          profileVisitedEventsModels: ProfileEventModels(
              events: allVisitedEvents.cast<OrganizedEventModel>(),
              total: visitedEvents?.total ?? 0,
              limit: visitedEvents?.limit ?? 0,
              offset: visitedEvents?.offset ?? 0),
          profileEventsModels: ProfileEventModels(
              events: allEvents.cast<OrganizedEventModel>(),
              total: events?.total ?? 0,
              limit: events?.limit ?? 0,
              offset: events?.offset ?? 0),
          isVerified: profile?.isEmailVerified ?? false,
          isProfileCompleted: profile?.isProfileCompleted ?? false,
          hasMoreEvents: events?.events.length == _pageLimit,
          hasMoreVisitedEvents: visitedEvents?.events.length == _pageLimit,
        ));
      } catch (e) {
        emit(ProfileGotListEventsErrorState());
      }
    });

    on<ProfileLogoutEvent>((event, emit) async {
      try {
        final isLogout = await AuthApi().authLogout();
        if (isLogout) {
          await storage.deleteAll();
          emit(ProfileLogoutState());
        }
      } catch (e) {
        emit(ProfileLogoutErrorState());
      }
    });

    on<ProfileDeleteEvent>((event, emit) async {
      try {
        final isDelete = await AuthApi().authDelete();
        if (isDelete) {
          await storage.deleteAll();
          emit(ProfileDeleteState());
        }
      } catch (e) {
        emit(ProfileDeleteErrorState());
      }
    });

    on<ProfileInviteUserEvent>((event, emit) async {
      try {
        final isInvited =
            await ProfileApi().inviteUser(event.userId, event.eventId);
        if (isInvited != null) {
          emit(ProfileInvitedUserState());
        }
      } catch (e) {
        emit(ProfileInvitedUserErrorState());
      }
    });

    on<ProfileRecommendUsersEvent>((event, emit) async {
      try {
        final recommendatedUsersModel =
            await EventsApi().getProfileRecommendedUsers(event.eventId);
        if (recommendatedUsersModel != null) {
          emit(ProfileRecommentedUsersState(
              recommendatedUsersModel: recommendatedUsersModel));
        }
      } catch (e) {
        emit(ProfileRecommentedUsersErrorState(errorText: 'Произошла ошибка'));
      }
    });
    on<ProfileGetEventDetailEvent>((event, emit) async {
      try {
        final eventDetail = await EventsApi().getProfileEvent(event.eventId);
        final profile = await ProfileApi().getProfile();
        final rewiews = await EventsApi().getReviewEvent(event.eventId);
        if (eventDetail != null && profile != null) {
          emit(ProfileGotEventDetailState(
              eventModel: eventDetail,
              profileModel: profile,
              rewiews: rewiews));
        }
      } catch (e) {
        emit(ProfileGotEventDetailErrorState(e.toString()));
      }
    });

    on<ProfileBlockUserEvent>((event, emit) async {
      try {
        final isBlocked = await ProfileApi().blockUser(event.userId);
        if (isBlocked != null) {
          emit(ProfileBlockedUserState());
        }
      } catch (e) {
        emit(ProfileBlockedUserErrorState());
      }
    });
    on<ProfileCancelActivityEvent>((event, emit) async {
      try {
        final isCanceled =
            await EventsApi().cancelActivity(event.eventId, event.isRecurring);
        if (isCanceled != null) {
          emit(ProfileCanceledActivityState());
        }
      } catch (e) {
        final jsonStr = e.toString().replaceFirst('Error: ', '');
        // Удаляем префикс "Exception: "
        String cleanJson = jsonStr.replaceFirst('Exception: ', '');

        // Парсим строку как JSON
        Map<String, dynamic> data = json.decode(cleanJson);

        // Достаём значение по ключу "detail"
        String detail = data['detail'];
        emit(ProfileCanceledActivityErrorState(errorText: detail));
      }
    });

    on<ProfileAcceptUserOnActivityEvent>((event, emit) async {
      try {
        final isConfirmed = await EventsApi()
            .acceptUserOnActivity(event.eventId, event.userId, event.status);
        if (isConfirmed != null) {
          final eventDetail = await EventsApi().getProfileEvent(event.eventId);
          emit(ProfileAcceptedUserOnActivityState(
              userId: event.userId, participants: eventDetail!.participants));
        }
      } catch (e) {
        emit(ProfileAcceptedUserOnActivityErrorState());
      }
    });

    on<ProfileReportUser>((event, emit) async {
      try {
        final isReported = await EventsApi()
            .reportUser(event.imageUrl, event.title, event.userId);
        if (isReported != null) {
          emit(ProfileReportedUserState());
        }
      } catch (e) {
        emit(ProfileReportedUserErrorState(errorText: 'Произошла ошибка'));
      }
    });

    on<ProfilePostReviewEvent>((event, emit) async {
      try {
        developer.log(
          '=== Начало отправки отзыва ===\n'
          'ID мероприятия: ${event.eventId}\n'
          'Данные отзыва: ${event.reviewPost.toJson()}',
          name: 'ProfileBloc',
        );

        final isPosted = await EventsApi().postReviewEvent(
          event.reviewPost,
          event.eventId,
        );

        if (isPosted != null) {
          developer.log('Отзыв успешно отправлен', name: 'ProfileBloc');
          emit(ProfilePostedReviewState());
        }
      } catch (e) {
        developer.log(
          '=== Ошибка при отправке отзыва ===\n'
          'Тип ошибки: ${e.runtimeType}\n'
          'Сообщение: $e',
          name: 'ProfileBloc',
          error: e,
        );

        String errorMessage = 'Произошла ошибка при отправке отзыва';
        if (e.toString().contains('Connection refused')) {
          errorMessage =
              'Нет подключения к серверу. Проверьте интернет-соединение';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Превышено время ожидания ответа от сервера';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Сессия истекла. Пожалуйста, войдите снова';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Нет прав для выполнения операции';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Ошибка на сервере. Попробуйте позже';
        }

        emit(ProfilePostedReviewErrorState(errorText: errorMessage));
      }
    });
  }
}
