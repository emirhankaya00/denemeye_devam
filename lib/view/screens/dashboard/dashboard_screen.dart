import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../view_models/dashboard_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold ve AppBar, RootScreen'da yönetildiği için
    // burası doğrudan arka plan rengiyle başlar.
    return Container(
      color: AppColors.background, // 1. Arka plan rengi güncellendi.
      child: const _DashboardContent(),
    );
  }
}

// ANA İÇERİK WIDGET'I
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return Column(
      children: [
        Expanded(
          child: viewModel.isLoading && viewModel.nearbySaloons.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => viewModel.fetchDashboardData(),
            color: AppColors.primaryColor, // Refresh indicator rengi
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/map_placeholder.png', // Bu görseli asset'lerde tuttuğundan emin ol
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SectionTitle(title: 'Yakınlardaki Salonlar'),
                  SaloonList(saloons: viewModel.nearbySaloons),
                  const SectionDivider(),
                  const SectionTitle(title: 'En Yüksek Puanlılar'),
                  SaloonList(saloons: viewModel.topRatedSaloons),
                  const SectionDivider(),
                  const SectionTitle(title: 'Kampanyalar'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: AppFonts.poppinsBold(
          fontSize: 18,
          // 2. Başlık metin rengi güncellendi.
          color: AppColors.textPrimary,
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
      // 3. Ayırıcı (divider) rengi güncellendi.
      child: Divider(color: AppColors.borderColor, thickness: 1),
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
      return SizedBox(
        height: 100,
        child: Center(
            child: Text(
              "Bu kategoride salon bulunamadı.",
              // 4. Boş liste mesajının rengi güncellendi.
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            )),
      );
    }
    return SizedBox(
      height: 285, // SalonCard boyutuna göre ayarlandı, gerekirse değiştirilebilir.
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames =
          salon.services.map((s) => s.serviceName).toList();
          return SalonCard(
            salonId: salon.saloonId,
            name: salon.saloonName,
            rating: '4.8', // Bu değer dinamik olarak gelmeli
            services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
            hasCampaign: hasCampaign,
            // SalonCard'ın kendi içinde de yeni renkleri kullandığından emin olmalıyız.
          );
        },
      ),
    );
  }
}