import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart'; // AppFonts'u import ettiğinizden emin olun!
import 'package:provider/provider.dart'; // Provider paketi için
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart'; // SearchViewModel eklendi

class Appointment {
  final String salonName;
  final String date;
  final String time;
  final String service;
  final double rating;
  final bool isUpcoming; // Gelecek randevu mu, geçmiş randevu mu
  final bool canCancel; // İptal edilebilir mi (sadece gelecek randevular için)

  Appointment({
    required this.salonName,
    required this.date,
    required this.time,
    required this.service,
    required this.rating,
    required this.isUpcoming,
    this.canCancel = false,
  });
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // TextEditingController _searchController kaldırıldı, çünkü arama RootScreen'daki AppBar'dan yönetiliyor.

  // Örnek randevu verileri
  final List<Appointment> _allAppointments = [
    Appointment(
      salonName: 'Mustafa Güzellik Salonu 1',
      date: '15 Tem 2025',
      time: '14:00',
      service: 'Saç Bakımı',
      rating: 4.5,
      isUpcoming: true,
      canCancel: true,
    ),
    Appointment(
      salonName: 'Premium Salon 2',
      date: '20 Tem 2025',
      time: '11:00',
      service: 'Manikür',
      rating: 4.8,
      isUpcoming: true,
      canCancel: true,
    ),
    Appointment(
      salonName: 'Fırsat Salonu 3',
      date: '10 Haz 2025',
      time: '16:00',
      service: 'Tırnak Bakımı',
      rating: 4.2,
      isUpcoming: false,
      canCancel: false,
    ),
    Appointment(
      salonName: 'Deniz Kuaför',
      date: '05 May 2025',
      time: '09:00',
      service: 'Saç Kesimi',
      rating: 4.0,
      isUpcoming: false,
      canCancel: false,
    ),
    Appointment(
      salonName: 'Yıldız Güzellik',
      date: '25 Tem 2025',
      time: '17:00',
      service: 'Makyaj',
      rating: 4.6,
      isUpcoming: true,
      canCancel: true,
    ),
  ];

  // _filteredAppointments artık build metodu içinde dinamik olarak oluşturulacak
  // List<Appointment> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    // _filteredAppointments = List.from(_allAppointments); // Artık gerek yok, Consumer içinde filtreleyeceğiz
    // _searchController.addListener(_onSearchChanged); // Kaldırıldı
  }

  @override
  void dispose() {
    // _searchController.removeListener(_onSearchChanged); // Kaldırıldı
    // _searchController.dispose(); // Kaldırıldı
    super.dispose();
  }

  // _onSearchChanged kaldırıldı
  // void _onSearchChanged() {
  //   _filterAppointments(_searchController.text);
  // }

  // _filterAppointments metodu da artık doğrudan SearchViewModel'dan gelen sorguyu alacak
  // void _filterAppointments(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       _filteredAppointments = List.from(_allAppointments);
  //     } else {
  //       _filteredAppointments = _allAppointments.where((appointment) {
  //         final String lowerCaseQuery = query.toLowerCase();
  //         return appointment.salonName.toLowerCase().contains(lowerCaseQuery) ||
  //             appointment.service.toLowerCase().contains(lowerCaseQuery);
  //       }).toList();
  //     }
  //   });
  // }

  void _cancelAppointment(Appointment appointment) {
    setState(() {
      _allAppointments.remove(appointment);
      // Listeyi yeniden filtrelemek için SearchViewModel'dan mevcut sorguyu al
      final currentSearchQuery = Provider.of<SearchViewModel>(context, listen: false).searchQuery;
      // Not: Bu kısımda normalde bir ViewModel'a taşınmış olsaydı, _allAppointments
      // direkt ViewModel içinde yönetilirdi ve burada sadece ViewModel'daki
      // bir metot çağrılırdı. Şimdilik bu setState yeterli.
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${appointment.salonName} için randevu iptal edildi.')),
    );
  }

  void _rebookAppointment(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${appointment.salonName} için randevu yeniden oluşturuluyor.')),
    );
    setState(() {
      _allAppointments.add(Appointment(
        salonName: appointment.salonName,
        date: 'Yeni Tarih', // Gerçek bir tarih seçimi olabilir
        time: 'Yeni Saat', // Gerçek bir saat seçimi olabilir
        service: appointment.service,
        rating: appointment.rating,
        isUpcoming: true,
        canCancel: true,
      ));
      // Yeniden rezervasyon sonrası da filtrelemeyi tetikle
      final currentSearchQuery = Provider.of<SearchViewModel>(context, listen: false).searchQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    // SearchViewModel'ı dinleyerek arama sorgusunu alıyoruz
    final searchViewModel = context.watch<SearchViewModel>();

    // Arama sorgusuna göre randevuları filtrele
    final List<Appointment> filteredAppointments = searchViewModel.searchQuery.isEmpty
        ? _allAppointments
        : _allAppointments.where((appointment) {
      final String lowerCaseQuery = searchViewModel.searchQuery.toLowerCase();
      return appointment.salonName.toLowerCase().contains(lowerCaseQuery) ||
          appointment.service.toLowerCase().contains(lowerCaseQuery);
    }).toList();

    final List<Appointment> upcomingAppointments = filteredAppointments
        .where((a) => a.isUpcoming)
        .toList();
    final List<Appointment> pastAppointments = filteredAppointments
        .where((a) => !a.isUpcoming)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.accentColor, // Ekranın genel arka plan rengi
      // AppBar'ı buradan kaldırdık. Artık RootScreen'daki MainApp yönetecek.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundColorLight,
              AppColors.backgroundColorDark,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gelecek Randevularım Bölümü
              Text(
                'Gelecek Randevularım',
                style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
              ),
              const SizedBox(height: 10),
              upcomingAppointments.isEmpty
                  ? _buildNoAppointmentsMessage('Yaklaşan randevunuz bulunmamaktadır.', searchViewModel.searchQuery.isNotEmpty)
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Kaydırmayı engelle
                itemCount: upcomingAppointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(upcomingAppointments[index]);
                },
              ),
              const SizedBox(height: 30),

              // Geçmiş Randevularım Bölümü
              Text(
                'Geçmiş Randevularım',
                style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
              ),
              const SizedBox(height: 10),
              pastAppointments.isEmpty
                  ? _buildNoAppointmentsMessage('Geçmiş randevunuz bulunmamaktadır.', searchViewModel.searchQuery.isNotEmpty)
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Kaydırmayı engelle
                itemCount: pastAppointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(pastAppointments[index]);
                },
              ),
            ],
          ),
        ),
      ),
      // Alt bar DashboardScreen'da yönetildiği için burada yok.
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // withValues yerine withOpacity kullanıldı
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Üstten hizala
        children: [
          // Sol İkon/Placeholder (Görseldeki gibi kare ve ikonlu)
          Container(
            width: 70, // Görseldeki gibi biraz daha büyük
            height: 70, // Görseldeki gibi biraz daha büyük
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.8), // withValues yerine withOpacity kullanıldı
              borderRadius: BorderRadius.circular(15), // Daha yuvarlak köşeler
            ),
            child: const Center(
              child: Icon(Icons.cut, color: Colors.white, size: 35), // Örnek ikon
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start, // Salon adı ve butonun üstten hizalanması
                  children: [
                    Expanded( // Salon adının taşmasını engelle
                      child: Text(
                        appointment.salonName,
                        style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                        overflow: TextOverflow.ellipsis, // Taşma durumunda ... göster
                        maxLines: 1, // Tek satırda kalmasını sağla
                      ),
                    ),
                    const SizedBox(width: 8), // Buton ile salon adı arasında boşluk
                    // Sağ üstteki ikon/buton
                    if (appointment.isUpcoming) // Gelecek randevuysa
                      if (appointment.canCancel) // Ve iptal edilebilirse
                      // İptal Et butonu
                        SizedBox(
                          height: 30, // Buton yüksekliğini ayarla
                          child: ElevatedButton(
                            onPressed: () => _cancelAppointment(appointment),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: Size.zero, // Minimum boyutu sıfırla
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Dokunma alanını küçült
                            ),
                            child: const Text('İptal et', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        )
                      else
                      // Konum ikonu (sadece ikon)
                        Icon(Icons.location_on, color: AppColors.iconColor, size: 30)
                    else // Geçmiş randevuysa
                    // Yeniden Oluştur butonu
                      SizedBox(
                        height: 30, // Buton yüksekliğini ayarla
                        child: ElevatedButton(
                          onPressed: () => _rebookAppointment(appointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: Size.zero, // Minimum boyutu sıfırla
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Dokunma alanını küçült
                          ),
                          child: const Text('Yeniden Oluştur', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                // Yapılacak İşlem: ve etiket
                Row(
                  children: [
                    Text(
                      'Yapılacak İşlem: ',
                      style: AppFonts.bodySmall(color: AppColors.textColorLight),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        appointment.service,
                        style: AppFonts.bodySmall(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Yıldızlar
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < appointment.rating.floor() ? Icons.star : Icons.star_border,
                        color: AppColors.starColor,
                        size: 18,
                      );
                    }),
                    const SizedBox(width: 5),
                    Text(
                      '${appointment.rating}',
                      style: AppFonts.bodySmall(color: AppColors.textColorLight),
                    ),
                  ],
                ),
                // Tarih/Saat sadece gelecek randevular için
                if (appointment.isUpcoming) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tarih: ${appointment.date} Saat: ${appointment.time}',
                    style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                  ),
                ],
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor.withOpacity(0.8), // withValues yerine withOpacity kullanıldı
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(isSearching ? Icons.search_off : Icons.event_busy, size: 80, color: AppColors.textColorLight.withAlpha(128)),
            const SizedBox(height: 20),
            Text(
              message,
              style: AppFonts.bodyMedium(color: AppColors.textColorLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}