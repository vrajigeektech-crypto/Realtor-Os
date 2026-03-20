// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Performs a same-tab full-page redirect to [url] using
/// `window.location.href`. After FUB OAuth, the browser returns to the app
/// at `/#/oauth/callback?code=...`.
void redirectToUrl(String url) {
  html.window.location.href = url;
}
