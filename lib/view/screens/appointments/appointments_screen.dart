// lib/features/appointments/screens/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/reservation_model.dart';
import '../../view_models/appointments_viewmodel.dart';
import '../../view_models/search_viewmodel.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentsViewModel>(context, listen: false)
          .fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentsViewModel, SearchViewModel>(
      builder: (context, appointmentsViewModel, searchViewModel, child) {
        final allAppointments = appointmentsViewModel.allAppointments;

        final List<ReservationModel> filteredAppointments =
        searchViewModel.searchQuery.isEmpty
            ? allAppointments
            : allAppointments.where((reservation) {
          final query = searchViewModel.searchQuery.toLowerCase();
          final salonName =
              reservation.saloon?.saloonName.toLowerCase() ?? '';
          final serviceName =
              reservation.service?.serviceName.toLowerCase() ?? '';
          return salonName.contains(query) ||
              serviceName.contains(query);
        }).toList();

        final now = DateTime.now();
        final List<ReservationModel> upcomingAppointments =
        filteredAppointments.where((r) {
          final reservationDateTime = r.reservationDate.add(Duration(
              hours: int.parse(r.reservationTime.split(':')[0]),
              minutes: int.parse(r.reservationTime.split(':')[1])));
          return reservationDateTime.isAfter(now) &&
              (r.status == ReservationStatus.confirmed ||
                  r.status == ReservationStatus.pending);
        }).toList();

        final List<ReservationModel> allPastAppointments =
        filteredAppointments.where((r) {
          final reservationDateTime = r.reservationDate.add(Duration(
              hours: int.parse(r.reservationTime.split(':')[0]),
              minutes: int.parse(r.reservationTime.split(':')[1])));
          return reservationDateTime.isBefore(now) ||
              r.status == ReservationStatus.cancelled ||
              r.status == ReservationStatus.completed ||
              r.status == ReservationStatus.noShow;
        }).toList();
        allPastAppointments.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
        final List<ReservationModel> pastAppointments = allPastAppointments.take(5).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: appointmentsViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: appointmentsViewModel.fetchAppointments,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gelecek Randevularım',
                    style: AppFonts.poppinsBold(
                        fontSize: 18, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  upcomingAppointments.isEmpty
                      ? _buildNoAppointmentsMessage(
                      'Yaklaşan randevunuz bulunmamaktadır.',
                      searchViewModel.searchQuery.isNotEmpty)
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(
                          context, upcomingAppointments[index]);
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Geçmiş Randevularım',
                    style: AppFonts.poppinsBold(
                        fontSize: 18, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  pastAppointments.isEmpty
                      ? _buildNoAppointmentsMessage(
                      'Geçmiş randevunuz bulunmamaktadır.',
                      searchViewModel.searchQuery.isNotEmpty)
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pastAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(
                          context, pastAppointments[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, ReservationModel reservation) {
    final now = DateTime.now();
    final reservationDateTime = reservation.reservationDate.add(Duration(
        hours: int.parse(reservation.reservationTime.split(':')[0]),
        minutes: int.parse(reservation.reservationTime.split(':')[1])));
    final bool isUpcoming = reservationDateTime.isAfter(now) &&
        (reservation.status == ReservationStatus.confirmed ||
            reservation.status == ReservationStatus.pending);

    final appointmentsViewModel =
    Provider.of<AppointmentsViewModel>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              image: reservation.saloon?.titlePhotoUrl != null &&
                  reservation.saloon!.titlePhotoUrl!.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(reservation.saloon!.titlePhotoUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: reservation.saloon?.titlePhotoUrl == null ||
                reservation.saloon!.titlePhotoUrl!.isEmpty
                ? Center(
                child: Icon(Icons.cut, color: AppColors.primaryColor.withOpacity(0.6), size: 35))
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        reservation.saloon?.saloonName ?? 'Salon Bilgisi Yok',
                        style: AppFonts.poppinsBold(
                            fontSize: 18, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isUpcoming)
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Randevuyu İptal Et'),
                                content: const Text(
                                    'Bu randevuyu iptal etmek istediğinizden emin misiniz?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Vazgeç')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Evet, İptal Et', style: TextStyle(color: Colors.red.shade700))),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              try {
                                await appointmentsViewModel.cancelAppointment(
                                    reservation.reservationId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Randevu başarıyla iptal edildi.'),
                                        backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Hata: ${e.toString()}'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }}
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('İptal et',
                              style:
                              TextStyle(color: Colors.red.shade700, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Yapılacak İşlem: ${reservation.service?.serviceName ?? 'Bilinmiyor'}',
                  style: AppFonts.bodySmall(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tarih: ${DateFormat.yMMMMd('tr_TR').format(reservation.reservationDate)} Saat: ${reservation.reservationTime}',
                  style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 5),
                // --- HATA DÜZELTMESİ BURADA ---
                Text(
                  'Durum: ${reservation.status.name}',
                  // fontWeight parametresi yerine .copyWith() metodu kullanıldı.
                  style: AppFonts.bodyMedium(color: AppColors.primaryColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAppointmentsMessage(String message, bool isSearching) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(isSearching ? Icons.search_off : Icons.event_busy,
                size: 80, color: AppColors.iconColor.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'Arama kriterlerinize uygun randevu bulunamadı.'
                  : message,
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}