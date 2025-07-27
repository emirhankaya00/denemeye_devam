// lib/view/screens/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/reservation_model.dart';
import '../../view_models/appointments_viewmodel.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _showUpcoming = true;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AppointmentsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.allAppointments.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          final now = DateTime.now();
          final upcomingAppointments = viewModel.allAppointments.where((r) {
            final reservationDateTime = r.reservationDate.add(Duration(
                hours: int.parse(r.reservationTime.split(':')[0]),
                minutes: int.parse(r.reservationTime.split(':')[1])));
            return reservationDateTime.isAfter(now) &&
                (r.status == ReservationStatus.confirmed || r.status == ReservationStatus.pending);
          }).toList();

          final pastAppointments = viewModel.allAppointments.where((r) {
            final reservationDateTime = r.reservationDate.add(Duration(
                hours: int.parse(r.reservationTime.split(':')[0]),
                minutes: int.parse(r.reservationTime.split(':')[1])));
            return reservationDateTime.isBefore(now) ||
                r.status == ReservationStatus.cancelled ||
                r.status == ReservationStatus.completed ||
                r.status == ReservationStatus.noShow;
          }).toList();

          pastAppointments.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));

          final displayedAppointments = _showUpcoming ? upcomingAppointments : pastAppointments;

          return RefreshIndicator(
            onRefresh: viewModel.fetchAppointments,
            color: AppColors.primaryColor,
            child: Column(
              children: [
                _buildToggleButtons(),
                Expanded(
                  child: displayedAppointments.isEmpty
                      ? _buildNoAppointmentsMessage(
                    _showUpcoming
                        ? 'Yaklaşan randevunuz bulunmamaktadır.'
                        : 'Geçmiş randevunuz bulunmamaktadır.',
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: displayedAppointments.length,
                    itemBuilder: (context, index) {
                      final reservation = displayedAppointments[index];
                      // YENİ: Hangi kartın gösterileceğini seçen koşullu yapı
                      if (_showUpcoming) {
                        return _buildUpcomingAppointmentCard(context, reservation);
                      } else {
                        return _buildPastAppointmentCard(context, reservation);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleButtons() {
    // Bu widget aynı kalıyor.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.borderColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showUpcoming = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _showUpcoming ? AppColors.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Gelecek Randevularım',
                    textAlign: TextAlign.center,
                    style: AppFonts.bodyMedium(
                      color: _showUpcoming ? AppColors.textOnPrimary : AppColors.textSecondary,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showUpcoming = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_showUpcoming ? AppColors.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Geçmiş Randevularım',
                    textAlign: TextAlign.center,
                    style: AppFonts.bodyMedium(
                      color: !_showUpcoming ? AppColors.textOnPrimary : AppColors.textSecondary,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DEĞİŞİKLİK: Metodun adı daha anlaşılır olacak şekilde değiştirildi.
  Widget _buildUpcomingAppointmentCard(BuildContext context, ReservationModel reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                Icon(Icons.favorite_border, color: AppColors.iconColor.withValues(alpha: 0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reservation.saloon?.saloonAddress ?? 'Adres bilgisi yok',
              style: AppFonts.bodySmall(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              reservation.service?.serviceName ?? "Hizmet Bilgisi Yok",
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat.yMMMMd('tr_TR').format(reservation.reservationDate)} • \$${reservation.totalPrice.toStringAsFixed(2)}',
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () { /* İptal etme logiği */ },
                  child: Text(
                    'Randevuyu iptal et',
                    style: AppFonts.bodyMedium(color: Colors.red.shade700),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () { /* Düzenleme talep etme logiği */ },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Düzenleme talep et'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // YENİ: Sadece geçmiş randevular için tasarlanan yeni kart metodu
  Widget _buildPastAppointmentCard(BuildContext context, ReservationModel reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppColors.primaryColor.withValues(alpha: 0.03), // Çok hafif renkli arka plan
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                Icon(Icons.favorite, color: AppColors.iconColor.withValues(alpha: 0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reservation.saloon?.saloonAddress ?? 'Adres bilgisi yok',
              style: AppFonts.bodySmall(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              reservation.service?.serviceName ?? "Hizmet Bilgisi Yok",
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat.yMMMMd('tr_TR').format(reservation.reservationDate)} • \$${reservation.totalPrice.toStringAsFixed(2)}',
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Butonları sağa yasla
              children: [
                ElevatedButton(
                  onPressed: () { /* Hizmet detayına gitme logiği */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hizmet Detayı'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () { /* Tekrar randevu oluşturma logiği */ },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Tekrar Oluştur'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAppointmentsMessage(String message) {
    // Bu widget aynı kalıyor.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 80, color: AppColors.iconColor.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.poppinsHeaderTitle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}