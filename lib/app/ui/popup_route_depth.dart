import 'package:flutter/material.dart';

/// Tracks how many [PopupRoute]s (menus, dialogs, etc.) are currently presented.
///
/// [GameScreen] listens and applies blur/tint only to its scroll body so overlays
/// stay sharp (they are not descendants of that subtree).
final ValueNotifier<int> popupRouteDepthNotifier = ValueNotifier<int>(0);

void _decrementPopupDepth() {
  final v = popupRouteDepthNotifier.value;
  if (v <= 0) {
    return;
  }
  popupRouteDepthNotifier.value = v - 1;
}

/// Bumps [popupRouteDepthNotifier] when [PopupRoute]s are pushed/popped.
///
/// Must be a long-lived instance referenced from [MaterialApp.navigatorObservers].
final class PopupRouteDepthObserver extends NavigatorObserver {
  static bool _isPopupRoute(Route<dynamic> route) =>
      route is PopupRoute<dynamic>;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isPopupRoute(route)) {
      // Apply blur after the first frame so underlying layout (scroll/ImageFiltered)
      // doesn’t shift coordinates while the popup measures position. Skip if already gone.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) {
          popupRouteDepthNotifier.value++;
        }
      });
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isPopupRoute(route)) {
      _decrementPopupDepth();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isPopupRoute(route)) {
      _decrementPopupDepth();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null && _isPopupRoute(oldRoute)) {
      _decrementPopupDepth();
    }
    if (newRoute != null && _isPopupRoute(newRoute)) {
      final Route<dynamic> pushed = newRoute;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pushed.isActive) {
          popupRouteDepthNotifier.value++;
        }
      });
    }
  }
}
