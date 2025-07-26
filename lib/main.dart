// lib/main.dart
import 'package:denemeye_devam/view/screens/auth/home_page.dart';
import 'package:denemeye_devam/view/screens/root_screen.dart';
import 'package:denemeye_devam/view/view_models/appointments_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/auth_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/dashboard_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/favorites_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences eklendi

import 'core/theme/app_colors.dart';
import 'view/screens/auth/onboarding_screen.dart'; // OnboardingScreen eklendi

bool _showOnboarding = true; // Onboarding ekranını göstermek için global değişken

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // shared_preferences ile onboarding durumunu kontrol et
  final prefs = await SharedPreferences.getInstance();
  _showOnboarding = prefs.getBool('hasSeenOnboarding') ?? true; // Eğer daha önce görülmediyse true

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

    Widget initialScreen;

    if (_showOnboarding) {
      initialScreen = const OnboardingScreen(); // Onboarding ekranını göster
    } else if (isLoggedIn) {
      initialScreen = const RootScreen(); // Giriş yapmışsa RootScreen'i göster
    } else {
      initialScreen = const HomePage(); // Giriş yapmamışsa HomePage'i göster
    }

    return MaterialApp(
      title: 'Salon Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: initialScreen, // Başlangıç ekranını ayarla
    );
  }
}