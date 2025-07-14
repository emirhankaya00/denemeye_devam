import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/features/appointments/screens/appointments_screen.dart';
import 'package:denemeye_devam/features/common/widgets/salon_card.dart';
import 'package:denemeye_devam/models/SaloonModel.dart';
import 'package:denemeye_devam/screens/favorites_screen.dart';
import 'package:denemeye_devam/screens/search_screen.dart';
import 'package:denemeye_devam/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _DashboardContent(onSearchTap: () => setState(() => _selectedIndex = 2)),
      const AppointmentsScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      Center(
        child: Text(
          'Profil Sayfası',
          style: AppFonts.poppinsBold(
            fontSize: 24,
            color: AppColors.textColorDark,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}

// ANA İÇERİK WIDGET'I
class _DashboardContent extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _DashboardContent({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return Column(
      children: [
        _TopBar(onSearchTap: onSearchTap),
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

// --- YARDIMCI WIDGET'LAR ---

class _TopBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _TopBar({required this.onSearchTap});
  @override
  Widget build(BuildContext context) {
    // ... (Bu widget'ın içeriği önceki cevapla aynı, değişmedi)
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      color: AppColors.primaryColor,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textColorLight),
                    const SizedBox(width: 8),
                    Text(
                      'Ara...',
                      style: AppFonts.bodyMedium(
                        color: AppColors.textColorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthViewModel>(context, listen: false).signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.textColorDark),
                    const SizedBox(width: 8),
                    Text(
                      'Çıkış Yap',
                      style: AppFonts.bodyMedium(
                        color: AppColors.textColorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
