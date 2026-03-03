enum SpeedToLeadMetricKey {
  responseTime('response_time'),
  firstContact('first_contact'),
  bpaSent('bpa_sent'),
  bpaSigned('bpa_signed'),
  conversion('conversion');

  final String key;
  const SpeedToLeadMetricKey(this.key);

  static SpeedToLeadMetricKey fromString(String value) {
    return SpeedToLeadMetricKey.values.firstWhere(
      (e) => e.key == value,
      orElse: () => SpeedToLeadMetricKey.responseTime,
    );
  }
}
