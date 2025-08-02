import 'package:cached_network_image/cached_network_image.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../features/appointments/screens/salon_detail_screen.dart';

/// Artık bir kart gibi görünmeyen, düz bir içerik widget'ı.
class SalonCard extends StatefulWidget {
  final String name;
  final String rating;
  final String description;
  final List<String> services;
  final String? imagePath;

  const SalonCard({
    super.key,
    required this.name,
    required this.rating,
    required this.description,
    required this.services,
    this.imagePath,
  });

  @override
  _SalonCardState createState() => _SalonCardState();
}

class _SalonCardState extends State<SalonCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final name = widget.name;
    final rating = widget.rating;
    final description = widget.description;
    final services = widget.services;
    final imagePath = widget.imagePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: imagePath != null && imagePath!.isNotEmpty
                ? CachedNetworkImage( // <-- Image.network yerine bu kullanılıyor
              imageUrl: imagePath!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0, color: AppColors.primaryColor)),
              ),
              errorWidget: (context, url, error) => _buildPlaceholderIcon(),
            )
                : _buildPlaceholderIcon(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppFonts.h6Bold(color: AppColors.textColorDark), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(description, style: AppFonts.bodySmall(color: AppColors.textColorLight), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.starColor, size: 18),
                  const SizedBox(width: 4),
                  Text(rating, style: AppFonts.bodyMedium(color: AppColors.textColorLight)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceTag(service, index == services.length - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(color: Colors.grey.shade100, child: Center(child: Icon(Icons.store, size: 50, color: Colors.grey.shade400)));
  }

  Widget _buildServiceTag(String service, bool isLast) {
    return Container(
      margin: EdgeInsets.only(right: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(service, style: AppFonts.bodySmall(color: AppColors.primaryColor))),
    );
  }
}

// ===================================================================
// 2. Ana Ekran Yapısı (State Yönetimi Optimize Edildi)
// ===================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // initState'te artık sadece konumu almayı tetikliyoruz. Bu işlem UI'ı bloklamaz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).initLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: _DashboardContent(),
    );
  }
}

// ===================================================================
// 3. İçerik Widget'ı (Asenkron Yükleme Entegre Edildi)
// ===================================================================
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  late Future<List<SaloonModel>> _nearbySaloonsFuture;
  late Future<List<SaloonModel>> _topRatedSaloonsFuture;
  late Future<List<SaloonModel>> _campaignSaloonsFuture;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<DashboardViewModel>(context, listen: false);
    _nearbySaloonsFuture = vm.getNearbySaloons();
    _topRatedSaloonsFuture = vm.getTopRatedSaloons();
    _campaignSaloonsFuture = vm.getCampaignSaloons();
  }

  Widget build(BuildContext context) {
    // ViewModel'e erişim sağlıyoruz. `listen: true` olduğu için
    // ViewModel'deki değişiklikler (konum, hata durumu vb.) bu widget'ı yeniden çizecektir.
    final vm = Provider.of<DashboardViewModel>(context);
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        setState(() {
          _nearbySaloonsFuture = vm.getNearbySaloons();
          _topRatedSaloonsFuture = vm.getTopRatedSaloons();
          _campaignSaloonsFuture = vm.getCampaignSaloons();
        });
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ——— Harita Bölümü ———
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Alt katman: harita veya placeholder
                      vm.currentPosition != null
                          ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            vm.currentPosition!.latitude,
                            vm.currentPosition!.longitude,
                          ),
                          zoom: 14,
                        ),
                        onMapCreated: vm.onMapCreated,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('user'),
                            position: LatLng(
                              vm.currentPosition!.latitude,
                              vm.currentPosition!.longitude,
                            ),
                          ),
                        },
                      )
                          : Container(color: Colors.grey.shade200),

                      // Üst katman: izin yoksa buton
                      if (vm.currentPosition == null)
                        Positioned.fill(
                          child: Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.location_searching),
                              label: const Text('Konum iznini tekrar iste'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Provider.of<DashboardViewModel>(
                                  context,
                                  listen: false,
                                ).initLocation();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ——— Salon listeleri ———
            const SectionTitle(title: 'Yakınlarda bulunan salonlar'),
            _buildSaloonSection(_nearbySaloonsFuture, "Yakında salon bulunamadı."),
            const SectionDivider(),
            const SectionTitle(title: 'En yüksek puanlı salonlar'),
            _buildSaloonSection(_topRatedSaloonsFuture, "Yüksek puanlı salon bulunamadı."),
            const SectionDivider(),
            const SectionTitle(title: 'Kampanyadaki salonlar'),
            _buildSaloonSection(_campaignSaloonsFuture, "Kampanyalı salon bulunamadı."),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // FutureBuilder'ları tekrar etmemek için yardımcı bir metod.
  Widget _buildSaloonSection(Future<List<SaloonModel>> future, String emptyMessage) {
    return FutureBuilder<List<SaloonModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SaloonListSkeleton();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return SaloonList(saloons: snapshot.data!);
        }
        return SizedBox(height: 100, child: Center(child: Text(emptyMessage)));
      },
    );
  }
}

// ===================================================================
// 4. İskelet Yükleyici ve Diğer Yardımcı Widget'lar
// ===================================================================
class SaloonListSkeleton extends StatelessWidget {
  const SaloonListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15.0))),
                const SizedBox(height: 12),
                Container(height: 20, width: 200, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(height: 14, width: 250, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SaloonList extends StatelessWidget {
  final List<SaloonModel> saloons;
  const SaloonList({super.key, required this.saloons});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames = salon.services.map((s) => s.serviceName).toList();
          return Container(
            width: 300,
            margin: EdgeInsets.only(right: index == saloons.length - 1 ? 0 : 16),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SalonDetailScreen(salonId: salon.saloonId))),
              borderRadius: BorderRadius.circular(15.0),
              child: SalonCard(
                name: salon.saloonName,
                rating: salon.avgRating?.toStringAsFixed(1) ?? 'N/A',
                description: salon.saloonAddress ?? 'Adres bilgisi yok',
                services: serviceNames.isNotEmpty ? serviceNames : ["Güzellik Merkezi", "Bakım"],
                imagePath: salon.titlePhotoUrl,
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        title,
        style: AppFonts.h5Bold(
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Divider(
          color: AppColors.dividerColor.withOpacity(0.5), thickness: 1),
    );
  }
}