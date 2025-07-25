// lib/main.dart
import 'package:denemeye_devam/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:denemeye_devam/presentation/screens/root_screen.dart';
import 'package:denemeye_devam/presentation/view_models/appointments_viewmodel.dart';
import 'package:denemeye_devam/presentation/view_models/auth_viewmodel.dart';
import 'package:denemeye_devam/presentation/view_models/dashboard_viewmodel.dart';
import 'package:denemeye_devam/presentation/view_models/favorites_viewmodel.dart';
import 'package:denemeye_devam/presentation/view_models/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // flutter_dotenv import edildi

import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);

  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    // .env dosyasından değerleri oku
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
    // Supabase oturumunu kontrol et
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

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
      home: isLoggedIn ? const RootScreen() : const DashboardScreen(),
    );
  }
}