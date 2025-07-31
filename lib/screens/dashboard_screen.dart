import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/features/common/widgets/salon_card.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
class _DashboardContent extends StatefulWidget {
  const _DashboardContent({Key? key}) : super(key: key);

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);

    if (vm.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userLatLng = LatLng(
      vm.currentPosition!.latitude,
      vm.currentPosition!.longitude,
    );

    return Column(
      children: [
        Expanded(
          child: vm.isLoading && vm.nearbySaloons.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () async {
              await vm.fetchDashboardData();
              vm.moveCameraToUser();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Harita bölümü
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            GoogleMap(
                              padding: const EdgeInsets.only(top: 80),
                              initialCameraPosition: CameraPosition(
                                target: userLatLng,
                                zoom: 14,
                              ),
                              onMapCreated: vm.onMapCreated,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: false,
                              markers: {
                                Marker(
                                  markerId: const MarkerId('user'),
                                  position: userLatLng,
                                ),
                              },
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.fullscreen),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => FullScreenMapPage(
                                          initialPosition: userLatLng,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Salon listeleri
                  const SectionTitle(title: 'Yakınlarda bulunan salonlar'),
                  SaloonList(saloons: vm.nearbySaloons),
                  const SectionDivider(),

                  const SectionTitle(title: 'En yüksek puanlı salonlar'),
                  SaloonList(saloons: vm.topRatedSaloons),
                  const SectionDivider(),

                  const SectionTitle(title: 'Kampanyadaki salonlar'),
                  SaloonList(
                    saloons: vm.campaignSaloons,
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


/// Tam ekran harita sayfası
class FullScreenMapPage extends StatelessWidget {
  final LatLng initialPosition;

  const FullScreenMapPage({Key? key, required this.initialPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Harita')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 14,
        ),
        onMapCreated: vm.onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        markers: {
          Marker(
            markerId: const MarkerId('user'),
            position: initialPosition,
          ),
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