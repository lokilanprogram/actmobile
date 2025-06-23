import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/presentation/screens/events/screens/detail_vote_event_screen.dart';
import 'package:acti_mobile/presentation/screens/events/widgets/vote_event_card.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:acti_mobile/presentation/screens/events/providers/vote_provider.dart';

class VotesScreen extends StatefulWidget {
  const VotesScreen({super.key});

  @override
  State<VotesScreen> createState() => _VotesScreenState();
}

class _VotesScreenState extends State<VotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  List<dynamic> _searchSuggestions = [];
  bool _searchLoading = false;
  OverlayEntry? _autocompleteOverlay;

  @override
  void initState() {
    super.initState();
    // Используем Future.microtask для отложенной инициализации
    Future.microtask(() => _fetchVotes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchVotes() async {
    if (!mounted) return;

    final voteProvider = Provider.of<VoteProvider>(context, listen: false);
    voteProvider.setLoading(true);

    try {
      final votes = await EventsApi().getVotesList();
      if (!mounted) return;
      voteProvider.setVotes(votes);
    } catch (e) {
      if (!mounted) return;
      voteProvider.setVotes([]);
      developer.log('Ошибка при загрузке голосований: $e');
    } finally {
      if (!mounted) return;
      voteProvider.setLoading(false);
    }
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchSuggestions = [];
      });
      _removeAutocompleteOverlay();
      return;
    }
    if (!mounted) return;
    setState(() {
      _searchLoading = true;
    });
    try {
      final votes = await EventsApi().getVotesList();
      if (!mounted) return;
      setState(() {
        _searchSuggestions = votes
            .where((vote) =>
                vote.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
      _showAutocompleteOverlay();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchSuggestions = [];
      });
      _removeAutocompleteOverlay();
    }
    if (!mounted) return;
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
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _searchLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, idx) {
                        final vote = _searchSuggestions[idx];
                        return ListTile(
                          leading: vote.photos.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    vote.photos.first,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.event,
                                          color: Colors.grey),
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
                                  child: const Icon(Icons.event,
                                      color: Colors.grey),
                                ),
                          title: Text(vote.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: vote.address != null
                              ? Text(vote.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12))
                              : null,
                          onTap: () {
                            _searchController.text = vote.title;
                            _removeAutocompleteOverlay();
                            FocusScope.of(context).unfocus();
                            _fetchVotes();
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

    return Consumer<VoteProvider>(
      builder: (context, voteProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    // Используем MainScreenProvider для перехода на индекс 1
                    Provider.of<MainScreenProvider>(context, listen: false)
                        .setIndex(1);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                Text(
                  'Голосование',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    // fontSize: isSmallScreen ? 16 : 18,
                  ),
                ),
                Container(width: 40),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 53,
                key: _searchFieldKey,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
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
                    _fetchVotes();
                  },
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Поиск по голосованиям',
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
                        ),
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              if (!mounted) return;
                              setState(() {
                                _searchController.clear();
                                _searchSuggestions = [];
                              });
                              _removeAutocompleteOverlay();
                            },
                          ),
                        PopupMenuButton<int>(
                          icon: SvgPicture.asset(
                            'assets/icons/sorting.svg',
                            height: 16,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (value) {
                            if (value == 0) {
                              voteProvider.votes
                                  .sort((a, b) => a.votes.compareTo(b.votes));
                            } else {
                              voteProvider.votes
                                  .sort((a, b) => b.votes.compareTo(a.votes));
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 0,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_upward,
                                      color: mainBlueColor),
                                  const SizedBox(width: 10),
                                  const Text('По возрастанию голосов'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_downward,
                                      color: mainBlueColor),
                                  const SizedBox(width: 10),
                                  const Text('По убыванию голосов'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
            // actions: [
            //   PopupMenuButton<int>(
            //     icon: SvgPicture.asset(
            //       'assets/icons/sorting.svg',
            //       height: 16,
            //     ),
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     onSelected: (value) {
            //       if (value == 0) {
            //         voteProvider.votes
            //             .sort((a, b) => a.votes.compareTo(b.votes));
            //       } else {
            //         voteProvider.votes
            //             .sort((a, b) => b.votes.compareTo(a.votes));
            //       }
            //     },
            //     itemBuilder: (context) => [
            //       PopupMenuItem(
            //         value: 0,
            //         child: Row(
            //           children: [
            //             Icon(Icons.arrow_upward, color: mainBlueColor),
            //             const SizedBox(width: 10),
            //             const Text('По возрастанию голосов'),
            //           ],
            //         ),
            //       ),
            //       PopupMenuItem(
            //         value: 1,
            //         child: Row(
            //           children: [
            //             Icon(Icons.arrow_downward, color: mainBlueColor),
            //             const SizedBox(width: 10),
            //             const Text('По убыванию голосов'),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ],
          ),
          body: voteProvider.isLoading
              ? const LoaderWidget()
              : RefreshIndicator(
                  onRefresh: _fetchVotes,
                  child: voteProvider.votes.isEmpty
                      ? Center(
                          child: Text(
                            'Ничего не нашлось',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: voteProvider.votes.length,
                          itemBuilder: (context, idx) {
                            final vote = voteProvider.votes[idx];
                            return VoteEventCard(
                              vote: vote,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailVoteEventScreen(
                                      eventId: vote.id,
                                      userVoted: vote.userVoted,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
        );
      },
    );
  }
}
