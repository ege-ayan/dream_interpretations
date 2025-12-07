import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/firebase_options.dart';
import 'screens/main_navigation.dart';
import 'screens/login/login_view.dart';
import 'services/auth_service.dart';
import 'services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      try {
        await RevenueCatService().initialize(user.uid);
      } catch (e) {
        debugPrint('RevenueCat initialization error: $e');
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return MaterialApp(
      title: 'Rüya Tabirleri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF9C27B0),
          secondary: const Color(0xFF7B1FA2),
          tertiary: const Color(0xFF4A148C),
          surface: const Color(0xFF1A1A2E),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFFE0E0E0),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF9C27B0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A148C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A2E),
          selectedItemColor: Color(0xFF9C27B0),
          unselectedItemColor: Color(0xFF666666),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: StreamBuilder(
        stream: auth.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const MainNavigation();
            } else {
              return const LoginView();
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
