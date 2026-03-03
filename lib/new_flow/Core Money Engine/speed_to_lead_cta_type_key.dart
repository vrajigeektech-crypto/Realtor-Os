enum SpeedToLeadCtaTypeKey {
  aiCall('ai_call'),
  manualFollowUp('manual_follow_up'),
  routeToPlan('route_to_plan');

  final String key;
  const SpeedToLeadCtaTypeKey(this.key);

  static SpeedToLeadCtaTypeKey fromString(String value) {
    return SpeedToLeadCtaTypeKey.values.firstWhere(
      (e) => e.key == value,
      orElse: () => SpeedToLeadCtaTypeKey.aiCall,
    );
  }
}
