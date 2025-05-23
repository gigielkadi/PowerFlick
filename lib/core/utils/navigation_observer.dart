import 'package:flutter/material.dart';

class NavigationLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('NAVIGATION: Pushed ${route.settings.name} (from ${previousRoute?.settings.name})');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('NAVIGATION: Popped ${route.settings.name} (back to ${previousRoute?.settings.name})');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('NAVIGATION: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('NAVIGATION: Removed ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }
} 