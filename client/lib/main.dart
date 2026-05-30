import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/app_navigator.dart';
import 'providers/auth_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/property_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RoomMatchApp());
}

class RoomMatchApp extends StatelessWidget {
  const RoomMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'RoomMatch',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD946A6)),
          useMaterial3: true,
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.status == AuthStatus.authenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
