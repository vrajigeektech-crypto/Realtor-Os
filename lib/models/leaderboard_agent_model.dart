// leaderboard_agent_model.dart
import '../ui/widgets/leaderboard_outcome_badge.dart';

class LeaderboardAgent {
  const LeaderboardAgent({
    required this.id,
    required this.fullName,
    required this.initials,
    this.subLabel = '',
    required this.rank,
    required this.role,
    required this.productionVolume,
    required this.score,
    required this.activityTrendPoints,
    required this.activityTrendColor,
    required this.outcomeLabel,
    required this.outcomeTone,
    this.showStars = false,
  });

  final String id;
  final String fullName;
  final String initials;
  final String subLabel;

  final int rank;
  final String role; // "Team Lead", "Broker", "Agent"
  final String productionVolume; // e.g., "$2.4M"
  final num score; // BPA Usage Score

  final List<double> activityTrendPoints;
  final ActivityTrendColor activityTrendColor; // green, red, blue/purple

  final String outcomeLabel;
  final OutcomeTone outcomeTone;
  final bool showStars; // For "Highly Active" outcomes

  String get rankDisplay => rank.toString();
  String get scoreDisplay => score.toString();

  factory LeaderboardAgent.fromMap(Map<String, dynamic> map) {
    return LeaderboardAgent(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      initials: map['initials'] as String,
      subLabel: (map['sub_label'] ?? '') as String,
      rank: map['rank'] as int,
      role: map['role'] as String? ?? 'Agent',
      productionVolume: map['production_volume'] as String? ?? '\$0',
      score: map['score'] as num,
      activityTrendPoints: (map['activity_trend_points'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      activityTrendColor: _parseTrendColor(map['activity_trend_color']),
      outcomeLabel: map['outcome_label'] as String,
      outcomeTone: _parseOutcomeTone(map['outcome_tone']),
      showStars: map['show_stars'] as bool? ?? false,
    );
  }

  static ActivityTrendColor _parseTrendColor(dynamic v) {
    switch (v) {
      case 'green':
        return ActivityTrendColor.green;
      case 'red':
        return ActivityTrendColor.red;
      case 'blue':
      case 'purple':
        return ActivityTrendColor.blue;
      default:
        return ActivityTrendColor.green;
    }
  }

  static OutcomeTone _parseOutcomeTone(dynamic v) {
    switch (v) {
      case 'good':
        return OutcomeTone.good;
      case 'warning':
        return OutcomeTone.warning;
      case 'bad':
        return OutcomeTone.bad;
      case 'neutral':
      default:
        return OutcomeTone.neutral;
    }
  }
}

enum LeaderboardSort {
  rank,
  agent,
  role,
  productionVolume,
  score,
  trend,
  outcome,
}

enum ActivityTrendColor {
  green,
  red,
  blue,
}
