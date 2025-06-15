import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/all_events_model.dart' as all_events;
import 'package:acti_mobile/data/models/event_adapter.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';

import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:acti_mobile/presentation/widgets/activity_bar_widget.dart';

import 'package:acti_mobile/presentation/widgets/loader_widget.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
import 'package:acti_mobile/presentation/screens/events/screens/detail_vote_event_screen.dart';
import 'package:acti_mobile/presentation/screens/events/widgets/filter_bottom_sheet.dart';
import 'package:acti_mobile/presentation/screens/events/widgets/vote_event_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acti_mobile/presentation/screens/events/providers/vote_provider.dart';
import 'package:acti_mobile/presentation/screens/events/screens/votes_screen.dart';
import 'package:get/get.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

class TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeRange(this.startTime, this.endTime);
}

class EventsScreen extends StatefulWidget {
  final all_events.AllEventsModel? initialEvents;
  const EventsScreen({super.key, this.initialEvents});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool isLoading = false;
  bool isVerified = false;
  bool isProfileCompleted = false;
  String selectedTab = 'all';
  all_events.AllEventsModel? eventsModel;
  final TextEditingController _searchController = TextEditingController();
  geolocator.Position? _currentPosition;
  bool _isInitialized = false;

  // Параметры пагинации
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  // --- Для автокомплита поиска ---
  final FocusNode _searchFocusNode = FocusNode();
  List<all_events.Event> _searchSuggestions = [];
  bool _searchLoading = false;
  OverlayEntry? _autocompleteOverlay;

  final GlobalKey _searchFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _applyFilters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      if (widget.initialEvents != null) {
        setState(() {
          eventsModel = widget.initialEvents;
        });
      } else {
        _applyFilters();
      }
    }
  }

  @override
  void didUpdateWidget(EventsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialEvents != oldWidget.initialEvents) {
      setState(() {
        eventsModel = widget.initialEvents;
      });
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    // Запускаем получение геолокации и профиля параллельно
    _getCurrentLocation();
    context.read<ProfileBloc>().add(ProfileGetListEventsEvent());

    try {
      developer.log('Загрузка событий в EventsScreen:', name: 'EVENTS_SCREEN');
      developer.log(
          'Координаты: ${_currentPosition?.latitude ?? 55.751244}, ${_currentPosition?.longitude ?? 37.618423}',
          name: 'EVENTS_SCREEN');

      final events = await EventsApi().searchEvents(
        latitude: _currentPosition?.latitude ?? 55.751244,
        longitude: _currentPosition?.longitude ?? 37.618423,
        radius: 50, // Уменьшаем радиус до 50 км
        limit: 20, // Уменьшаем лимит до 20
        offset: 0, // Добавляем offset
      );

      developer.log('Получено событий: ${events?.events.length ?? 0}',
          name: 'EVENTS_SCREEN');

      if (mounted) {
        setState(() {
          eventsModel = events;
          isLoading = false;
        });

        if (events == null || events.events.isEmpty) {
          developer.log('Для EventsScreen: События не найдены',
              name: 'EventsScreen');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ничего не нашлось'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      developer.log('Для EventsScreen: Ошибка при загрузке событий: $e',
          name: 'EventsScreen', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке событий: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied) return;
      }

      if (permission == geolocator.LocationPermission.deniedForever) return;

      _currentPosition = await geolocator.Geolocator.getCurrentPosition();
    } catch (e) {
      developer.log('Ошибка при получении геолокации: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _applyFilters({bool reset = true}) async {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);

    if (reset) {
      _offset = 0;
      _hasMore = true;
      setState(() {
        eventsModel = null;
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      // --- Формируем параметры длительности ---
      int? durationMin;
      int? durationMax;
      switch (filterProvider.selectedDurationFilter) {
        case 'short':
          durationMin = 0;
          durationMax = 2;
          break;
        case 'medium':
          durationMin = 3;
          durationMax = 5;
          break;
        case 'long':
          durationMin = 6;
          durationMax = 24;
          break;
      }

      // --- Формируем ограничения ---
      List<String> restrictions =
          List<String>.from(filterProvider.selectedAgeRestrictions);

      final int radius = filterProvider.selectedRadius.round() == 0
          ? 1
          : filterProvider.selectedRadius.round();
      final events = await EventsApi().searchEvents(
        latitude: filterProvider.selectedMapAddressModel?.latitude ??
            _currentPosition?.latitude ??
            55.751244,
        longitude: filterProvider.selectedMapAddressModel?.longitude ??
            _currentPosition?.longitude ??
            37.618423,
        radius: radius,
        address: filterProvider.selectedMapAddressModel != null
            ? null
            : (filterProvider.cityFilterText.isNotEmpty ? null : null),
        date_from: filterProvider.selectedDateFrom != null
            ? DateFormat('yyyy-MM-dd').format(filterProvider.selectedDateFrom!)
            : null,
        date_to: filterProvider.selectedDateTo != null
            ? DateFormat('yyyy-MM-dd').format(filterProvider.selectedDateTo!)
            : null,
        time_from: filterProvider.selectedTimeFrom,
        time_to: filterProvider.selectedTimeTo,
        type: filterProvider.isOnlineSelected ? 'online' : 'offline',
        price_min: filterProvider.priceMinText.isNotEmpty
            ? double.tryParse(filterProvider.priceMinText)
            : null,
        price_max: filterProvider.priceMaxText.isNotEmpty
            ? double.tryParse(filterProvider.priceMaxText)
            : null,
        restrictions: restrictions.isNotEmpty ? restrictions : null,
        category_ids: filterProvider.selectedCategoryIds.isEmpty
            ? null
            : filterProvider.selectedCategoryIds,
        duration_min: durationMin,
        duration_max: durationMax,
        slots_min: filterProvider.slotsMin,
        slots_max: filterProvider.slotsMax,
        search_query:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        offset: _offset,
        limit: _limit,
      );

      setState(() {
        if (reset) {
          eventsModel = events;
        } else {
          if (eventsModel != null && events != null) {
            eventsModel = all_events.AllEventsModel(
              total: events.total,
              limit: events.limit,
              offset: events.offset,
              events: [...eventsModel!.events, ...events.events],
            );
          }
        }
        isLoading = false;
        _hasMore = events != null && events.events.length == _limit;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      developer.log('Ошибка при загрузке событий с фильтрами: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке событий с фильтрации: $e')),
      );
    }
  }

  // Метод для подгрузки следующей страницы
  Future<void> _loadMoreEvents() async {
    if (!_hasMore || isLoading) return;
    _offset += _limit;
    await _applyFilters(reset: false);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentPosition: _currentPosition,
        onApplyFilters: () {
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _fetchVotes() async {
    final voteProvider = Provider.of<VoteProvider>(context, listen: false);
    voteProvider.setLoading(true);
    try {
      final votes = await EventsApi().getVotesList();
      voteProvider.setVotes(votes);
    } catch (e) {
      voteProvider.setVotes([]);
      developer.log('Ошибка при загрузке голосований: $e');
    } finally {
      voteProvider.setLoading(false);
    }
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
      });
      _removeAutocompleteOverlay();
      return;
    }
    setState(() {
      _searchLoading = true;
    });
    try {
      final events = await EventsApi().searchEvents(
        latitude: _currentPosition?.latitude ?? 55.751244,
        longitude: _currentPosition?.longitude ?? 37.618423,
        search_query: query,
        limit: 10,
      );
      setState(() {
        _searchSuggestions = events?.events.cast<all_events.Event>() ?? [];
      });
      _showAutocompleteOverlay();
    } catch (e) {
      setState(() {
        _searchSuggestions = [];
      });
      _removeAutocompleteOverlay();
    }
    setState(() {
      _searchLoading = false;
    });
  }

  void _showAutocompleteOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeAutocompleteOverlay();
      if (!_searchFocusNode.hasFocus || _searchSuggestions.isEmpty) return;
      final RenderBox box = context.findRenderObject() as RenderBox;
      final overlay = Overlay.of(context);
      final searchBox =
          _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (searchBox == null) return;
      final position = searchBox.localToGlobal(Offset.zero,
          ancestor: overlay.context.findRenderObject());
      _autocompleteOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: position.dx,
          top: position.dy + searchBox.size.height,
          width: searchBox.size.width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _searchLoading
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, idx) {
                        final event = _searchSuggestions[idx];
                        return ListTile(
                          leading: event.photos.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    event.photos.first,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey[200],
                                      child:
                                          Icon(Icons.event, color: Colors.grey),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.event, color: Colors.grey),
                                ),
                          title: Text(event.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: event.address != null
                              ? Text(event.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12))
                              : null,
                          onTap: () {
                            _searchController.text = event.title;
                            _removeAutocompleteOverlay();
                            FocusScope.of(context).unfocus();
                            _applyFilters();
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      );
      overlay.insert(_autocompleteOverlay!);
    });
  }

  void _removeAutocompleteOverlay() {
    _autocompleteOverlay?.remove();
    _autocompleteOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileGotListEventsState) {
          setState(() {
            isVerified = state.isVerified;
            isProfileCompleted = state.isProfileCompleted;
          });
        }
      },
      child: Consumer2<FilterProvider, VoteProvider>(
        builder: (context, filterProvider, voteProvider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            appBar: isLoading
                ? null
                : AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Container(width: 10),
                        SizedBox(
                          child: Text(
                            'События',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              // fontSize: isSmallScreen ? 16 : 18,
                              fontSize: 23,
                            ),
                          ),
                        ),
                        Container(
                          height: 32,
                          // width: isSmallScreen ? 110 : 120,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                mainBlueColor,
                                Color.fromRGBO(98, 207, 102, 1),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                            ),
                            onPressed: () {
                              // Используем MainScreenProvider для перехода на VotesScreen
                              Provider.of<MainScreenProvider>(context,
                                      listen: false)
                                  .setIndex(5);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Голосование',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    // fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 32,
                          width: 115,
                          margin: EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: mainBlueColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: InkWell(
                            onTap: () async {
                              _showFilterBottomSheet();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset('assets/icons/filter.svg'),
                                  SizedBox(width: 10),
                                  Text('Фильтры',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(60),
                      child: Container(
                        height: 53,
                        key: _searchFieldKey,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (value) {
                            _fetchSearchSuggestions(value);
                          },
                          onTap: () {
                            if (_searchController.text.isNotEmpty) {
                              _fetchSearchSuggestions(_searchController.text);
                            }
                          },
                          onEditingComplete: () {
                            _removeAutocompleteOverlay();
                            _applyFilters();
                          },
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Поиск по событиям',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                  height: 20,
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    height: 20,
                                    width: 20,
                                    colorFilter: ColorFilter.mode(
                                        Colors.grey[400]!, BlendMode.srcIn),
                                  )),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchSuggestions = [];
                                      });
                                      _removeAutocompleteOverlay();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                    ),
                    // actions: [
                    //   Container(
                    //     height: 32,
                    //     width: 115,
                    //     margin: EdgeInsets.only(right: 16.0),
                    //     decoration: BoxDecoration(
                    //       color: mainBlueColor,
                    //       borderRadius: BorderRadius.circular(30),
                    //     ),
                    //     child: InkWell(
                    //       onTap: () async {
                    //         _showFilterBottomSheet();
                    //       },
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: 12.0, vertical: 8.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             SvgPicture.asset('assets/icons/filter.svg'),
                    //             SizedBox(width: 10),
                    //             Text('Фильтры',
                    //                 style: TextStyle(
                    //                     color: Colors.white,
                    //                     fontWeight: FontWeight.w600,
                    //                     fontSize: 12)),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ),
            extendBody: true,
            body: isLoading
                ? LoaderWidget()
                : Stack(
                    children: [
                      Positioned.fill(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 0, bottom: 0),
                            child: Column(
                              children: [
                                const SizedBox(height: 25),
                                Expanded(
                                  child: eventsModel != null
                                      ? RefreshIndicator(
                                          onRefresh: () async {
                                            setState(() {
                                              _offset = 0;
                                              _hasMore = true;
                                            });
                                            await _applyFilters();
                                          },
                                          child: NotificationListener<
                                              ScrollNotification>(
                                            onNotification: (scrollInfo) {
                                              if (scrollInfo.metrics.pixels ==
                                                      scrollInfo.metrics
                                                          .maxScrollExtent &&
                                                  _hasMore &&
                                                  !isLoading) {
                                                _loadMoreEvents();
                                              }
                                              return false;
                                            },
                                            child: eventsModel!.events.isEmpty
                                                ? Center(
                                                    child: Text(
                                                      'Ничего не нашлось',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    itemCount: eventsModel!
                                                        .events.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final event = eventsModel!
                                                          .events[index];
                                                      return MyCardEventWidget(
                                                        organizedEvent: event
                                                            .toOrganizedEventModel(),
                                                        isPublicUser: true,
                                                        isCompletedEvent: false,
                                                      );
                                                    },
                                                  ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            'Загрузка событий...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 150),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
