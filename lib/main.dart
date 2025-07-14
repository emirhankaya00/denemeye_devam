// lib/main.dart
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/dashboard_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/screens/root_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/screens/home_page.dart';
// Eğer bir AuthViewModel'ın varsa onu da import et
// import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  await Supabase.initialize(
    url: '',
    anonKey: '',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
      // Kullanıcı giriş yaptıysa RootScreen'e, yapmadıysa HomePage'e git.
      // Bu, uygulamanın ilk açılışında doğru ekranı göstermesini sağlar.
      home: isLoggedIn ? const RootScreen() : const HomePage(),
      // Veya direkt olarak HomePage() ile başlayıp, HomePage içinde kontrolü yapabilirsin.
      // home: const HomePage(),
    );
  }
}
