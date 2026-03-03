// leaderboard_filter_model.dart
class LeaderboardFilters {
  const LeaderboardFilters({
    required this.periodKey,
    required this.teamId,
    required this.activityKey,
  });

  final String periodKey;
  final String teamId;
  final String activityKey;

  factory LeaderboardFilters.defaults() {
    return const LeaderboardFilters(
      periodKey: '30d',
      teamId: 'all',
      activityKey: 'all',
    );
  }

  LeaderboardFilters copyWith({
    String? periodKey,
    String? teamId,
    String? activityKey,
  }) {
    return LeaderboardFilters(
      periodKey: periodKey ?? this.periodKey,
      teamId: teamId ?? this.teamId,
      activityKey: activityKey ?? this.activityKey,
    );
  }
}

class LeaderboardPeriodOption {
  const LeaderboardPeriodOption({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;

  static List<LeaderboardPeriodOption> defaults() {
    return const [
      LeaderboardPeriodOption(key: '7d', label: 'Last 7 Days'),
      LeaderboardPeriodOption(key: '30d', label: 'Last 30 Days'),
      LeaderboardPeriodOption(key: '90d', label: 'Last 90 Days'),
    ];
  }
}

class LeaderboardTeamOption {
  const LeaderboardTeamOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  static List<LeaderboardTeamOption> defaults() {
    return const [
      LeaderboardTeamOption(id: 'all', label: 'All Teams'),
    ];
  }
}

class LeaderboardActivityOption {
  const LeaderboardActivityOption({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;

  static List<LeaderboardActivityOption> defaults() {
    return const [
      LeaderboardActivityOption(key: 'all', label: 'All Activity'),
      LeaderboardActivityOption(key: 'calls', label: 'Calls'),
      LeaderboardActivityOption(key: 'appointments', label: 'Appointments'),
      LeaderboardActivityOption(key: 'closings', label: 'Closings'),
    ];
  }
}
