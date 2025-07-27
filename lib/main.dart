import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// Home
import 'package:denemeye_devam/view/screens/auth/home_page.dart';

// Global ViewModels
import 'package:denemeye_devam/view/view_models/appointments_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/auth_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/dashboard_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/favorites_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/search_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/filter_viewmodel.dart';

// Repositories
import 'package:denemeye_devam/data/repositories/service_repository.dart';
import 'package:denemeye_devam/data/repositories/saloon_repository.dart';
import 'package:denemeye_devam/data/repositories/comment_repository.dart';
import 'package:denemeye_devam/data/repositories/reservation_repository.dart';
import 'package:denemeye_devam/data/repositories/favorites_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabaseClient = Supabase.instance.client;

  runApp(
    MultiProvider(
      providers: [
        // ───────────── Repositories (üstte) ─────────────
        Provider<ServiceRepository>(create: (_) => ServiceRepository()),
        Provider<SaloonRepository>(create: (_) => SaloonRepository(supabaseClient)),
        Provider<ReservationRepository>(create: (_) => ReservationRepository(supabaseClient)),
        Provider<FavoritesRepository>(create: (_) => FavoritesRepository(supabaseClient)),
        Provider<CommentRepository>(create: (_) => CommentRepository()),
        // NOT: Burada ikinci bir SaloonRepository TANIMLAMA. (Duble hatasına yol açar)

        // ───────────── Global ViewModels ─────────────
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentsViewModel()),
        ChangeNotifierProvider(
          create: (ctx) => FilterViewModel(
            ctx.read<ServiceRepository>(),
            ctx.read<SaloonRepository>(),
          ),
        ),

        // ÖNEMLİ:
        // SalonDetailViewModel ve CheckoutViewModel route‑scoped (ekran içinde) kurulacak.
        // Böylece saloonId gibi parametreleri ekranlardan geçebilir ve çakışma yaşamazsın.
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Uygulama temeli
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Denemeye Devam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
