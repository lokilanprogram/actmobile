import 'package:acti_mobile/data/models/all_events_model.dart' as all_events;
import 'package:acti_mobile/data/models/profile_event_model.dart'
    as profile_event;

extension EventAdapter on all_events.Event {
  profile_event.OrganizedEventModel toOrganizedEventModel() {
    return profile_event.OrganizedEventModel(
      id: id,
      title: title,
      description: description,
      category_id: categoryId,
      type: type,
      address: address ?? '',
      dateStart: dateStart,
      dateEnd: dateEnd,
      timeStart: timeStart,
      timeEnd: timeEnd,
      slots: slots,
      freeSlots: freeSlots,
      latitude: latitude,
      longitude: longitude,
      price: price,
      status: status,
      photos: photos,
      restrictions: restrictions,
      isRecurring: isRecurring,
      creator: creator.toProfileCreator(),
      participants: [],
      join_status: joinStatus,
      category: category.toProfileCategory(),
      isReported: false,
      creatorId: creatorId,
      rejectionReason: '',
    );
  }
}

extension CreatorAdapter on all_events.Creator {
  profile_event.Creator toProfileCreator() {
    return profile_event.Creator(
      id: id,
      name: name,
      surname: null,
      email: null,
      city: null,
      hasRecentBan: false,
      bio: null,
      isOrganization: isOrganization,
      photoUrl: photoUrl,
      status: null,
      isEmailVerified: false,
      isProfileCompleted: false,
    );
  }
}

extension CategoryAdapter on all_events.Category {
  profile_event.Category toProfileCategory() {
    return profile_event.Category(
      id: id,
      name: name,
      iconPath: iconPath,
    );
  }
}
 