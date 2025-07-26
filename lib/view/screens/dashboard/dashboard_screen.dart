// lib/view/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../view_models/dashboard_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';
import 'all_saloons_screen.dart';
import 'category_saloons_screen.dart'; // YENİ EKLENEN SAYFANIN IMPORT'U

// ... (DashboardScreen ve _DashboardContent widget'ları aynı kalıyor)
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

    void navigateToAllSaloons(String title, List<SaloonModel> saloons) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllSaloonsScreen(title: title, saloons: saloons),
        ),
      );
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
            const SectionTitle(title: 'Kategoriler'),
            const CategoryList(), // Bu widget'ı güncelleyeceğiz
            const FilterBar(),
            const SectionDivider(),
            SectionTitle(
              title: 'Yakınlardaki Salonlar',
              showSeeAll: true,
              onSeeAllPressed: () => navigateToAllSaloons('Yakınlardaki Salonlar', viewModel.nearbySaloons),
            ),
            SaloonList(saloons: viewModel.nearbySaloons),
            const SectionDivider(),
            SectionTitle(
              title: 'En Yüksek Puanlılar',
              showSeeAll: true,
              onSeeAllPressed: () => navigateToAllSaloons('En Yüksek Puanlılar', viewModel.topRatedSaloons),
            ),
            SaloonList(saloons: viewModel.topRatedSaloons),
            const SectionDivider(),
            SectionTitle(
              title: 'Kampanyalar',
              showSeeAll: true,
              onSeeAllPressed: () => navigateToAllSaloons('Kampanyalar', viewModel.campaignSaloons),
            ),
            SaloonList(saloons: viewModel.campaignSaloons),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}


// --- DEĞİŞİKLİK: CategoryList WIDGET'I GÜNCELLENDİ ---
class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {'name': 'Kişisel bakım', 'image': 'assets/images/iris_login_img_4.jpg'},
      {'name': 'Tüy alımı ve ağda', 'image': 'assets/images/iris_login_img_3.jpg'},
      {'name': 'Yüz ve cilt bakımı', 'image': 'assets/images/iris_login_img.jpg'},
      {'name': 'Manikür & Pedikür', 'image': 'assets/images/iris_login_img_2.jpg'},
    ];

    void navigateToCategory(String categoryName) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategorySaloonsScreen(categoryName: categoryName),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector( // Tıklanabilirlik için GestureDetector eklendi
            onTap: () => navigateToCategory(category['name']!),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage(category['image']!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name']!,
                    style: AppFonts.bodySmall(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// ... (FilterBar, SectionTitle, SectionDivider ve SaloonList widget'ları aynı kalıyor)
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          _buildFilterChip(label: 'Fiyat', icon: Icons.expand_more),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'İndirimler', icon: Icons.percent_outlined),
          const SizedBox(width: 8),
          _buildFilterChip(icon: Icons.star_border_outlined),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Filtrele', style: AppFonts.poppinsBold(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({String? label, required IconData icon}) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: label != null ? Text(label, style: AppFonts.bodyMedium(color: AppColors.textSecondary)) : const SizedBox(),
      style: OutlinedButton.styleFrom(
        padding: label != null ? const EdgeInsets.symmetric(horizontal: 12) : const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: AppColors.borderColor),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllPressed;

  const SectionTitle({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Row(
                children: [
                  Text(
                    'Tümünü gör',
                    style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
        ],
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
      child: Divider(color: AppColors.borderColor, thickness: 1),
    );
  }
}

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
      height: 350,
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