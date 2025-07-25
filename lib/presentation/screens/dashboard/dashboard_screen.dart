import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../view_models/dashboard_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';

// AuthViewModel import'ı kaldırıldı çünkü artık _TopBar burada değil.
// import '../viewmodels/auth_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // _selectedIndex ve _pages artık RootScreen tarafından yönetiliyor, burada gerekli değil.
  // int _selectedIndex = 0;
  // late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Dashboard verilerini çekmek için ViewModel'ı kullan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // DashboardContent'i doğrudan döndürüyoruz.
    // Scaffold ve AppBar artık RootScreen'daki MainApp tarafından sağlanacak.
    return const _DashboardContent();
  }
}

// ANA İÇERİK WIDGET'I
class _DashboardContent extends StatelessWidget {
  // onSearchTap parametresi artık _TopBar kaldırıldığı için gerekli değil.
  const _DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return Column( // Scaffold yerine Column kullanıyoruz, çünkü Scaffold ana RootScreen'da.
      children: [
        // _TopBar widget'ı kaldırıldı, AppBar artık RootScreen'da yönetiliyor.
        Expanded(
          child: viewModel.isLoading && viewModel.nearbySaloons.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => viewModel.fetchDashboardData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/map_placeholder.png',
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SectionTitle(
                    title: 'Yakınlarda bulunan salonlar',
                  ),
                  SaloonList(saloons: viewModel.nearbySaloons),
                  const SectionDivider(),
                  const SectionTitle(title: 'En yüksek puanlı salonlar'),
                  SaloonList(saloons: viewModel.topRatedSaloons),
                  const SectionDivider(),

                  // --- KAMPANYALI SALONLAR BÖLÜMÜNÜ GERİ EKLEDİK ---
                  const SectionTitle(title: 'Kampanyadaki salonlar'),
                  SaloonList(
                    saloons: viewModel.campaignSaloons,
                    hasCampaign: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: AppFonts.poppinsBold(
          fontSize: 18,
          color: AppColors.textColorDark,
        ),
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Divider(color: AppColors.dividerColor, thickness: 1),
    );
  }
}

class SaloonList extends StatelessWidget {
  final List<SaloonModel> saloons;
  final bool hasCampaign;
  const SaloonList({
    super.key,
    required this.saloons,
    this.hasCampaign = false,
  });

  @override
  Widget build(BuildContext context) {
    if (saloons.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("Bu kategoride salon bulunamadı.")),
      );
    }
    return SizedBox(
      height: 285,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames = salon.services
              .map((s) => s.serviceName)
              .toList();
          return SalonCard(
            salonId: salon.saloonId,
            name: salon.saloonName,
            rating: '4.8',
            services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
            hasCampaign: hasCampaign,
          );
        },
      ),
    );
  }
}