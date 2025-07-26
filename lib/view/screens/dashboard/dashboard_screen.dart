// lib/view/screens/dashboard/dashboard_screen.dart

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
    return Container(
      color: AppColors.background,
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    if (viewModel.isLoading && viewModel.nearbySaloons.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchDashboardData(),
      color: AppColors.primaryColor,
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
                  'assets/map_placeholder.png',
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
            SaloonList(saloons: viewModel.campaignSaloons),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// BÖLÜM BAŞLIĞI WIDGET'I
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      // --- DEĞİŞİKLİK BURADA ---
      // Alt boşluk 8.0'dan 16.0'a çıkarılarak daha ferah bir görünüm sağlandı.
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Text(
        title,
        style: AppFonts.poppinsHeaderTitle(),
      ),
    );
  }
}

// BÖLÜM AYIRICI WIDGET'I
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Divider(color: AppColors.borderColor, thickness: 1),
    );
  }
}

// SALON LİSTESİ WIDGET'I
class SaloonList extends StatelessWidget {
  final List<SaloonModel> saloons;

  const SaloonList({
    super.key,
    required this.saloons,
  });

  @override
  Widget build(BuildContext context) {
    if (saloons.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
            child: Text(
              "Bu kategoride salon bulunamadı.",
              style: TextStyle(color: AppColors.textSecondary),
            )),
      );
    }
    return SizedBox(
      height: 350, // Yükseklik son kart tasarımına göre ayarlanmıştı.
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames =
          salon.services.map((s) => s.serviceName).toList();

          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(right: 8.0),
            child: SalonCard(
              salonId: salon.saloonId,
              name: salon.saloonName,
              description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
              rating: '4.1', // Dinamik olarak gelmeli
              location: salon.saloonAddress?.split(',').first ?? 'Konum Yok',
              distance: '5 Km', // Bu değer hesaplanmalı
              services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
              imagePath: salon.titlePhotoUrl,
            ),
          );
        },
      ),
    );
  }
}