// Conditional export: on mobile/desktop (dart:io) use the no-op stub;
// on Flutter Web (dart:html) use the real implementation.
export 'web_redirect_web.dart' if (dart.library.io) 'web_redirect_stub.dart';
