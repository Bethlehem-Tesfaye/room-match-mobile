import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void _resetStack(Widget screen) {
  void go() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (_) => false,
    );
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => go());
}

/// Clears the entire stack and shows [HomeScreen] (e.g. after login/signup).
void navigateToHome() {
  _resetStack(const HomeScreen());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    final user = context.read<AuthProvider>().user;
    if (user != null && !user.isOwner) {
      context.read<FavoriteProvider>().loadFavorites(user.id);
    }
  });
}

/// Clears the entire stack and shows [LoginScreen] (e.g. after logout).
void navigateToLogin() => _resetStack(const LoginScreen());