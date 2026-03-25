import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Wired from [RealtorOSAppState] so login flows can refresh routing without
/// every [LoginScreen] needing a callback (e.g. after logout + `/login`).
Future<void> Function()? refreshAppAfterAuth;

GlobalKey<NavigatorState>? _rootNavigatorKey;

void registerRootNavigator(GlobalKey<NavigatorState> key) {
  _rootNavigatorKey = key;
}

/// Pops all pushed routes and returns to `/` so [MaterialApp.home] matches
/// the current session (main vs login vs onboarding).
void resetNavigatorToMatchHome() {
  final nav = _rootNavigatorKey?.currentState;
  if (nav == null) return;
  void go() {
    if (!nav.mounted) return;
    nav.pushNamedAndRemoveUntil('/', (route) => false);
  }

  // Run after the current frame so [refreshAppAfterAuth] can call setState first.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    SchedulerBinding.instance.addPostFrameCallback((_) => go());
  });
}
