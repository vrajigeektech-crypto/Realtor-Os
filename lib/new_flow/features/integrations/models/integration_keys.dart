/// Canonical integration keys used across:
/// - RPCs
/// - routing
/// - state management
/// - feature gating
/// 
/// DO NOT hardcode strings elsewhere.
/// Always reference from this file.

class IntegrationKeys {
  // PAYMENTS
  static const String stripe = 'stripe';

  // GOOGLE ECOSYSTEM
  static const String googleAds = 'google_ads';
  static const String googleAnalytics = 'google_analytics';
  static const String googleCalendar = 'google_calendar';
  static const String googleDrive = 'google_drive';
  static const String googleGmail = 'google_gmail';

  // SOCIAL
  static const String facebookAds = 'facebook_ads';
  static const String instagramAds = 'instagram_ads';

  // CRM
  static const String hubspot = 'hubspot';
  static const String salesforce = 'salesforce';

  // MARKETING / AUTOMATION
  static const String zapier = 'zapier';
  static const String mailchimp = 'mailchimp';

  // COMMUNICATION
  static const String twilio = 'twilio';
  static const String sendgrid = 'sendgrid';

  // STORAGE / FILES
  static const String dropbox = 'dropbox';

  static const List<String> all = [
    stripe,
    googleAds,
    googleAnalytics,
    googleCalendar,
    googleDrive,
    googleGmail,
    facebookAds,
    instagramAds,
    hubspot,
    salesforce,
    zapier,
    mailchimp,
    twilio,
    sendgrid,
    dropbox,
  ];
}
