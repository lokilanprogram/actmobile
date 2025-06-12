import 'dart:convert';

import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/public_user_model.dart';
import 'package:acti_mobile/data/models/recommendated_user_model.dart';
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
        final users = await ProfileApi().getSimiliarUsers();
        if (profile != null && users != null) {
          emit(ProfileGotState(
              profileModel: profile, similiarUsersModel: users));
        }
      } catch (e) {
        emit(ProfileGotErrorState());
      }
    });

    on<ProfileGetPublicUserEvent>((event, emit) async {
      try {
        final user = await ProfileApi().getPublicUser(event.userId);
        user.fold((l) {
          emit(ProfileGotPublicUserState(publicUserModel: l));
        }, (r) {
          emit(ProfileGotPublicUserErrorState(message: r.toString()));
        });
      } catch (e) {
        emit(ProfileGotPublicUserErrorState(message: e.toString()));
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
        final profile = await ProfileApi().updateProfile(
          event.profileModel,
        );
        if (event.profileModel.photoUrl != null) {
          await ProfileApi().updateProfilePicture(event.profileModel.photoUrl!);
        }
        final updatedProfile = await ProfileApi().getProfile();
        if (profile != null && updatedProfile != null) {
          emit(ProfileUpdatedState(profileModel: updatedProfile));
        }
      } catch (e) {
        emit(ProfileUpdatedErrorState());
      }
    });

    on<ProfileGetListEventsEvent>((event, emit) async {
      try {
        final profile = await ProfileApi().getProfile();
        if (profile != null) {
          final events = await ProfileApi().getProfileListEvents();
          final visitedEvents =
              await ProfileApi().getProfileVisitedListEvents();
          if (events != null)
            events.events.sort((a, b) => a.dateStart.compareTo(b.dateStart));
          if (visitedEvents != null)
            visitedEvents.events
                .sort((a, b) => a.dateStart.compareTo(b.dateStart));
          emit(ProfileGotListEventsState(
              profileVisitedEventsModels: visitedEvents,
              profileEventsModels: events,
              isVerified: profile.isEmailVerified,
              isProfileCompleted: profile.isProfileCompleted));
        }
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
        if (eventDetail != null && profile != null) {
          emit(ProfileGotEventDetailState(
              eventModel: eventDetail, profileModel: profile));
        }
      } catch (e) {
        emit(ProfileGotEventDetailErrorState());
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
  }
}
