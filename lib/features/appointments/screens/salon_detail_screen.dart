// GEREKLİ TÜM IMPORT'LAR BURADA
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/PersonalModel.dart';
import 'package:denemeye_devam/models/ServiceModel.dart';
import 'package:denemeye_devam/models/SaloonModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/favorites_viewmodel.dart';
import '../../../viewmodels/saloon_detail_viewmodel.dart';

class SalonDetailScreen extends StatefulWidget {
  final String salonId;

  const SalonDetailScreen({super.key, required this.salonId});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'ı bu ekran için özel olarak burada oluşturup sağlıyoruz.
    // Böylece her SalonDetay sayfası kendi ViewModel'ına sahip oluyor.
    return ChangeNotifierProvider(
      create: (_) => SalonDetailViewModel()..fetchSalonDetails(widget.salonId),
      child: Consumer<SalonDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(context),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.salon == null
                ? const Center(child: Text('Salon bilgileri alınamadı.'))
                : _buildContent(context, viewModel),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final salonDetailViewModel = context.read<SalonDetailViewModel>();
    final bool isCurrentlyFavorite = favoritesViewModel.isSalonFavorite(
      widget.salonId,
    );

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.arrow_back, color: AppColors.primaryColor),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // --- BU KISIM GÜNCELLENDİ ---
        IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4.0),
            // Favori durumuna göre dolu veya boş kalp göster
            child: Icon(
              isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
              color: isCurrentlyFavorite
                  ? Colors.red.shade400
                  : AppColors.primaryColor,
            ),
          ),
          // Butona basıldığında ViewModel'daki fonksiyonu çağır
          onPressed: () {
            favoritesViewModel.toggleFavorite(
              widget.salonId,
              salon: salonDetailViewModel
                  .salon, // Anlık güncelleme için salon bilgisini de yolla
            );
          },
        ),
        // ------------------------
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SalonDetailViewModel viewModel) {
    final salon = viewModel
        .salon!; // viewModel.salon null değil, kontrolü yukarıda yaptık.

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundColorLight,
                AppColors.backgroundColorDark,
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, salon),
              const SizedBox(height: 20),
              _buildSectionTitle('Takvim'),
              _buildCalendar(context, viewModel),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () =>
                      _showAppointmentBookingBottomSheet(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Randevu Al',
                    style: AppFonts.poppinsBold(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Hizmetler'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: salon.services.length,
                itemBuilder: (context, index) {
                  final service = salon.services[index];
                  return _buildServiceListItem(service);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, SaloonModel salon) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            child:
                salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                ? Image.network(
                    salon.titlePhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  )
                : Image.asset('assets/map_placeholder.png', fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.saloonName,
                    style: AppFonts.poppinsBold(
                      fontSize: 20,
                      color: AppColors.textColorDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    salon.saloonAddress ?? 'Adres belirtilmemiş',
                    style: AppFonts.bodySmall(color: AppColors.textColorLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel viewModel) {
    final List<DateTime> weekDates = List.generate(
      7,
      (i) => DateTime.now().add(Duration(days: i)),
    );

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = viewModel.selectedDate?.day == date.day;

          return GestureDetector(
            onTap: () => viewModel.selectNewDate(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentColor : AppColors.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColors.dividerColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'tr_TR').format(date),
                    style: AppFonts.bodyMedium(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textColorDark,
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(date),
                    style: AppFonts.poppinsBold(
                      fontSize: 20,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textColorDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceListItem(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.content_cut, size: 30, color: AppColors.iconColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: AppFonts.poppinsBold(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  '${service.estimatedTime.inMinutes} dk | ${service.basePrice} TL',
                  style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentBookingBottomSheet(
    BuildContext context,
    SalonDetailViewModel viewModel,
  ) {
    final List<String> timeSlots = [
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<SalonDetailViewModel>(
            builder: (context, vm, child) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColorLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Randevu Oluştur',
                        style: AppFonts.poppinsBold(fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Saat Seçimi'),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: timeSlots.map((time) {
                                final isSelected = vm.selectedTimeSlot == time;
                                return ChoiceChip(
                                  label: Text(time),
                                  selected: isSelected,
                                  onSelected: (_) => vm.selectTime(time),
                                  selectedColor: AppColors.accentColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionTitle('Hizmet Seçimi'),
                            ...vm.salon!.services.map((service) {
                              return RadioListTile<ServiceModel>(
                                title: Text(
                                  "${service.serviceName} (${service.basePrice} TL)",
                                ),
                                value: service,
                                groupValue: vm.selectedService,
                                onChanged: (val) =>
                                    vm.selectServiceForAppointment(val!),
                                activeColor: AppColors.primaryColor,
                              );
                            }).toList(),
                            const SizedBox(height: 20),
                            _buildSectionTitle('Çalışan Seçimi'),
                            ...vm.employees.map((employee) {
                              return RadioListTile<PersonalModel>(
                                title: Text(
                                  '${employee.name} ${employee.surname}',
                                ),
                                value: employee,
                                groupValue: vm.selectedEmployee,
                                onChanged: (val) =>
                                    vm.selectEmployeeForAppointment(val!),
                                activeColor: AppColors.primaryColor,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed:
                            vm.selectedTimeSlot != null &&
                                vm.selectedService != null &&
                                vm.selectedEmployee != null
                            ? () async {
                                try {
                                  await vm.createReservation();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Randevunuz başarıyla oluşturuldu!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Randevuyu Onayla'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
