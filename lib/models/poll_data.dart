class PollData {
  final String question;
  final List<String> options;
  final List<int> votes;
  final int? myVote;
  final DateTime? expiresAt;

  const PollData({
    required this.question,
    required this.options,
    this.votes = const [],
    this.myVote,
    this.expiresAt,
  });

  bool get hasVoted => myVote != null;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => !isExpired;

  PollData copyWith({
    String? question,
    List<String>? options,
    List<int>? votes,
    int? myVote,
    DateTime? expiresAt,
    bool clearMyVote = false,
  }) {
    return PollData(
      question: question ?? this.question,
      options: options ?? this.options,
      votes: votes ?? this.votes,
      myVote: clearMyVote ? null : (myVote ?? this.myVote),
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  static PollData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final options = (json['options'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    if (options.isEmpty) return null;

    final rawVotes = json['votes'] as List<dynamic>? ?? [];
    final votes = List<int>.generate(
      options.length,
      (i) => i < rawVotes.length ? (rawVotes[i] as num?)?.toInt() ?? 0 : 0,
    );

    final myVoteRaw = json['my_vote'];
    final myVote = myVoteRaw is num ? myVoteRaw.toInt() : null;

    DateTime? expiresAt;
    final expiresRaw = json['expires_at']?.toString();
    if (expiresRaw != null && expiresRaw.isNotEmpty) {
      expiresAt = DateTime.tryParse(expiresRaw);
    }

    return PollData(
      question: json['question']?.toString() ?? 'Poll',
      options: options,
      votes: votes,
      myVote: myVote,
      expiresAt: expiresAt,
    );
  }

  static PollData? parseLegacyCaption(String caption) {
    final trimmed = caption.trim();
    if (!trimmed.toLowerCase().contains('poll:')) return null;

    final pollIdx = trimmed.toLowerCase().indexOf('poll:');
    final body = trimmed.substring(pollIdx + 5).trim();
    if (body.isEmpty) return null;

    final optionRegex = RegExp(r'\s(\d+)\)\s*');
    final matches = optionRegex.allMatches(body).toList();
    if (matches.isEmpty) return null;

    final question = body.substring(0, matches.first.start).trim();
    final options = <String>[];

    for (var i = 0; i < matches.length; i++) {
      final start = matches[i].end;
      final end = i + 1 < matches.length ? matches[i + 1].start : body.length;
      final text = body.substring(start, end).trim();
      if (text.isNotEmpty) options.add(text);
    }

    if (options.isEmpty) return null;

    return PollData(
      question: question.isEmpty ? 'Poll' : question,
      options: options,
    );
  }

  Map<String, dynamic> toCreateJson({int durationDays = 7}) {
    return {
      'question': question,
      'options': options,
      'duration_days': durationDays,
    };
  }
}
