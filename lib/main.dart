// lib/main.dart
import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart'; // AppColors sınıfını import et
import 'package:denemeye_devam/screens/root_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- intl için gerekli import

void main() async { // <-- main fonksiyonu async yapıldı
  WidgetsFlutterBinding.ensureInitialized(); // <-- Flutter binding'in başlatıldığından emin ol
  await initializeDateFormatting('tr', null); // <-- Türkçe yerel veri başlatıldı

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const RootScreen(),
    );
  }
}