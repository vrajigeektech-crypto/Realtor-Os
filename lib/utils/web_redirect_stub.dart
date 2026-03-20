/// No-op on non-web platforms. URL redirection is handled by [url_launcher]
/// in the native [FollowUpBossAuthService.initiateAuth] path instead.
void redirectToUrl(String url) {}
