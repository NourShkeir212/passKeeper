import 'package:flutter/material.dart';

class NavigationService {
  // A GlobalKey to access the Navigator from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Private constructor to prevent instantiation
  NavigationService._();

  /// Navigates to a new page and allows going back.
  static Future<dynamic>? push(Widget page) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navigates to a new page and replaces the current page (no back).
  static Future<dynamic>? pushReplacement(Widget page) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navigates to a new page and removes all previous pages from the stack (no back).
  /// Ideal for post-login or post-logout navigation.
  static Future<dynamic>? pushAndRemoveUntil(Widget page) {
    return navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
          (Route<dynamic> route) => false, // This predicate removes all routes
    );
  }

  /// Goes back one page.
  static void pop() {
    return navigatorKey.currentState?.pop();
  }
}