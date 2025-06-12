import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/all_events_model.dart' as all_events;
import 'package:acti_mobile/data/models/event_adapter.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
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

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

class TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeRange(this.startTime, this.endTime);
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

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

  // --- Новый флаг для отображения голосования ---
  bool showVotes = false;

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Служба геолокации отключена')),
        );
        return;
      }

      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешение на геолокацию отклонено')),
          );
          return;
        }
      }

      if (permission == geolocator.LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Разрешение на геолокацию отклонено навсегда')),
        );
        return;
      }

      _currentPosition = await geolocator.Geolocator.getCurrentPosition();
    } catch (e) {
      developer.log('Ошибка при получении геолокации: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при получении геолокации: $e')),
      );
    }
  }

  @override
  void initState() {
    initialize();
    context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  initialize() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _getCurrentLocation();
      if (_currentPosition != null) {
        _applyFilters();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить геолокацию')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      developer.log('Ошибка при загрузке событий: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке событий: $e')),
      );
    }
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
    final isSmallScreen = MediaQuery.of(context).size.width < 400 &&
        MediaQuery.of(context).size.width > 250;
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        showVotes
                            ? IconButton(
                                onPressed: () async {
                                  setState(() {
                                    showVotes = !showVotes;
                                  });
                                  if (showVotes &&
                                      voteProvider.votes.isEmpty &&
                                      !voteProvider.isLoading) {
                                    await _fetchVotes();
                                  }
                                },
                                icon: Icon(Icons.arrow_back_ios_new),
                              )
                            : Container(
                                width: 10,
                              ),
                        SizedBox(
                          child: Text(
                            showVotes ? 'Голосование' : 'События',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 16 : 18,
                              // fontSize: 18,
                            ),
                          ),
                        ),
                        showVotes
                            ? Container()
                            : Container(
                                height: 32,
                                width: isSmallScreen ? 110 : 120,
                                margin: EdgeInsets.symmetric(horizontal: 12.0),
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
                                        horizontal: 6, vertical: 0),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      showVotes = !showVotes;
                                    });
                                    if (showVotes &&
                                        voteProvider.votes.isEmpty &&
                                        !voteProvider.isLoading) {
                                      await _fetchVotes();
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Голосование',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                      ),
                                    ],
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
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.clear,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchSuggestions = [];
                                          });
                                          _removeAutocompleteOverlay();
                                        },
                                      ),
                                      if (showVotes)
                                        PopupMenuButton<int>(
                                          icon: SvgPicture.asset(
                                            'assets/icons/sorting.svg',
                                            height: 16,
                                          ),
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          onSelected: (value) {
                                            setState(() {
                                              if (value == 0) {
                                                voteProvider.votes.sort((a,
                                                        b) =>
                                                    a.votes.compareTo(b.votes));
                                              } else {
                                                voteProvider.votes.sort((a,
                                                        b) =>
                                                    b.votes.compareTo(a.votes));
                                              }
                                            });
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 0,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.arrow_upward,
                                                      color: mainBlueColor),
                                                  SizedBox(width: 10),
                                                  Text(
                                                      'По возрастанию голосов'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 1,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.arrow_downward,
                                                      color: mainBlueColor),
                                                  SizedBox(width: 10),
                                                  Text('По убыванию голосов'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        IconButton(
                                          icon: SvgPicture.asset(
                                            'assets/icons/sorting.svg',
                                            height: 16,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchSuggestions = [];
                                            });
                                            _removeAutocompleteOverlay();
                                          },
                                        ),
                                    ],
                                  )
                                : (showVotes
                                    ? PopupMenuButton<int>(
                                        icon: SvgPicture.asset(
                                          'assets/icons/sorting.svg',
                                          height: 16,
                                        ),
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        onSelected: (value) {
                                          setState(() {
                                            if (value == 0) {
                                              voteProvider.votes.sort((a, b) =>
                                                  a.votes.compareTo(b.votes));
                                            } else {
                                              voteProvider.votes.sort((a, b) =>
                                                  b.votes.compareTo(a.votes));
                                            }
                                          });
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 0,
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_upward,
                                                    color: mainBlueColor),
                                                SizedBox(width: 10),
                                                Text('По возрастанию голосов'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 1,
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_downward,
                                                    color: mainBlueColor),
                                                SizedBox(width: 10),
                                                Text('По убыванию голосов'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/icons/sorting.svg',
                                          height: 16,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchSuggestions = [];
                                          });
                                          _removeAutocompleteOverlay();
                                        },
                                      )),
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
                    actions: [
                      if (!showVotes)
                        Container(
                          height: 32,
                          width: 115,
                          margin: EdgeInsets.only(right: 16.0),
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
            extendBody: true,
            body: isLoading
                ? LoaderWidget()
                : Stack(
                    children: [
                      Positioned.fill(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            child: Column(
                              children: [
                                const SizedBox(height: 25),
                                Expanded(
                                  child: showVotes
                                      ? (voteProvider.isLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : RefreshIndicator(
                                              onRefresh: _fetchVotes,
                                              child: voteProvider.votes.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                        'Ничего не нашлось',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      itemCount: voteProvider
                                                          .votes.length,
                                                      itemBuilder:
                                                          (context, idx) {
                                                        final vote =
                                                            voteProvider
                                                                .votes[idx];
                                                        return VoteEventCard(
                                                          vote: vote,
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DetailVoteEventScreen(
                                                                  eventId:
                                                                      vote.id,
                                                                  userVoted: vote
                                                                      .userVoted,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                            ))
                                      : (eventsModel != null
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
                                                  if (scrollInfo
                                                              .metrics.pixels ==
                                                          scrollInfo.metrics
                                                              .maxScrollExtent &&
                                                      _hasMore &&
                                                      !isLoading) {
                                                    _loadMoreEvents();
                                                  }
                                                  return false;
                                                },
                                                child: eventsModel!
                                                        .events.isEmpty
                                                    ? Center(
                                                        child: Text(
                                                          'Ничего не нашлось',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .grey[600],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      )
                                                    : ListView(
                                                        children: [
                                                          ...eventsModel!.events
                                                              .map((event) {
                                                            return MyCardEventWidget(
                                                              isCompletedEvent:
                                                                  false,
                                                              isPublicUser:
                                                                  true,
                                                              organizedEvent: event
                                                                  .toOrganizedEventModel(),
                                                            );
                                                          }),
                                                          if (_hasMore)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          16),
                                                              child: Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                            ),
                                                        ],
                                                      ),
                                              ),
                                            )
                                          : Container()),
                                ),
                                const SizedBox(height: 150),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ActivityBarWidget(
                                  isVerified: isVerified,
                                  isProfileCompleted: isProfileCompleted),
                              const SizedBox(height: 15),
                              CustomNavBarWidget(
                                selectedIndex: 1,
                                onTabSelected: (index) {
                                  if (index == 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MapScreen(selectedScreenIndex: 0),
                                      ),
                                    );
                                  }
                                  if (index == 2) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MapScreen(selectedScreenIndex: 2),
                                      ),
                                    );
                                  } else if (index == 3) {
                                    developer.log('Navigate to Profile');
                                  } else if (index == 1) {
                                    developer.log('Stay on Events Screen');
                                  }
                                },
                              ),
                            ],
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
