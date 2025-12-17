import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart' as app_auth;
import 'providers/scan_provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'core/theme.dart';

import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'screens/history_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app_auth.AuthProvider>(
          create: (_) => app_auth.AuthProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => DatabaseService()),
      ],

      child: Consumer2<app_auth.AuthProvider, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          final loggedIn = auth.user != null;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Crop Disease Detector',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            home: loggedIn ? const HomeScreen() : const LoginScreen(),

            routes: {
              ResultScreen.routeName: (context) => const ResultScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              RegisterScreen.routeName: (context) => const RegisterScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
