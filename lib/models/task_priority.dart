enum TaskPriority {
  low,
  normal,
  high,
  boosted,
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.normal:
        return 'Normal';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.boosted:
        return 'Boosted';
    }
  }

  bool get isHighlighted {
    return this == TaskPriority.high || this == TaskPriority.boosted;
  }
}
