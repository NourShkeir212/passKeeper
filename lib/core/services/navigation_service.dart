import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  NavigationService._();

  static Future<dynamic>? push(Widget page) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<dynamic>? pushReplacement(Widget page) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<dynamic>? pushAndRemoveUntil(Widget page) {
    return navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
          (Route<dynamic> route) => false,
    );
  }

  static void pop() {
    return navigatorKey.currentState?.pop();
  }
}