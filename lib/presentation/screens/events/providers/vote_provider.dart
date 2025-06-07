import 'package:flutter/foundation.dart';
import 'package:acti_mobile/data/models/all_events_model.dart' as all_events;

class VoteProvider extends ChangeNotifier {
  List<all_events.VoteModel> _votes = [];
  bool _isLoading = false;
  String _sortOrder = 'desc'; // 'asc' или 'desc'

  List<all_events.VoteModel> get votes => _votes;
  bool get isLoading => _isLoading;
  String get sortOrder => _sortOrder;

  void setVotes(List<all_events.VoteModel> votes) {
    _votes = votes;
    _sortVotes();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
    _sortVotes();
    notifyListeners();
  }

  void _sortVotes() {
    if (_sortOrder == 'asc') {
      _votes.sort((a, b) => a.votes.compareTo(b.votes));
    } else {
      _votes.sort((a, b) => b.votes.compareTo(a.votes));
    }
  }

  void updateVoteStatus(String eventId, bool hasVoted) {
    final index = _votes.indexWhere((vote) => vote.id == eventId);
    if (index != -1) {
      _votes[index] = _votes[index].copyWith(userVoted: hasVoted);
      notifyListeners();
    }
  }
}
