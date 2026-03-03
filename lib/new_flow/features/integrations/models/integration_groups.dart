import 'integration_keys.dart';

/// Defines how integrations are grouped in the UI.
/// This is purely PRESENTATION + ORGANIZATION logic.
/// No RPCs, no auth, no side effects.

class IntegrationGroups {
  static const String payments = 'payments';
  static const String google = 'google';
  static const String social = 'social';
  static const String crm = 'crm';
  static const String marketing = 'marketing';
  static const String communication = 'communication';
  static const String storage = 'storage';

  /// Ordered groups as they should appear in the UI
  static const List<String> orderedGroups = [
    payments,
    google,
    social,
    crm,
    marketing,
    communication,
    storage,
  ];

  /// Mapping of group → integration keys
  static const Map<String, List<String>> groupItems = {
    payments: [
      IntegrationKeys.stripe,
    ],

    google: [
      IntegrationKeys.googleAds,
      IntegrationKeys.googleAnalytics,
      IntegrationKeys.googleCalendar,
      IntegrationKeys.googleDrive,
      IntegrationKeys.googleGmail,
    ],

    social: [
      IntegrationKeys.facebookAds,
      IntegrationKeys.instagramAds,
    ],

    crm: [
      IntegrationKeys.hubspot,
      IntegrationKeys.salesforce,
    ],

    marketing: [
      IntegrationKeys.zapier,
      IntegrationKeys.mailchimp,
    ],

    communication: [
      IntegrationKeys.twilio,
      IntegrationKeys.sendgrid,
    ],

    storage: [
      IntegrationKeys.dropbox,
    ],
  };

  /// Human-readable titles
  static const Map<String, String> titles = {
    payments: 'Payments',
    google: 'Google Ecosystem',
    social: 'Social Media',
    crm: 'CRM',
    marketing: 'Marketing & Automation',
    communication: 'Communication',
    storage: 'Storage',
  };

  /// Subtitles shown under group headers
  static const Map<String, String> subtitles = {
    payments: 'Billing, payouts, and transactions',
    google: 'Ads, analytics, calendar, and email',
    social: 'Advertising and social signals',
    crm: 'Leads and client management',
    marketing: 'Campaigns and automation',
    communication: 'Messaging and notifications',
    storage: 'File and document storage',
  };
}
