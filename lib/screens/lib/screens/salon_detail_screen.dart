// 1. Dart SDK'sı importları
import 'dart:async';
import 'dart:io';

// 2. Flutter framework importu (genellikle ilk)
import 'package:flutter/material.dart';

// 3. Diğer üçüncü taraf paketlerin importları
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:intl/date_symbol_data_local.dart'; // initializeDateFormatting için

// 4. Kendi projenizin içindeki diğer dosyaların importları
import 'package:denemeye_devam/app_colors.dart'; // AppColors sınıfı için
import 'package:denemeye_devam/app_fonts.dart'; // AppFonts sınıfı için

// Not: Bu sayfa için artık bu importlara doğrudan gerek yok,
// çünkü detay ekranından genellikle Dashboard veya ana sayfaya geri dönülür.
// import 'package:denemeye_devam/screens/home_page.dart';
// import 'package:denemeye_devam/widgets/some_new_widget.dart';


class SalonDetailScreen extends StatefulWidget {
  final String salonName;

  const SalonDetailScreen({super.key, required this.salonName});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  // Mevcut takvim verilerini dinamik olarak oluşturmak için
  List<DateTime> _weekDates = [];
  int _selectedDateIndex = 0;
  DateTime _selectedDate = DateTime.now(); // Seçilen tarihi tutmak için
  String? _selectedTimeSlot; // Seçilen saat dilimi
  String? _selectedServiceType; // Randevu alınacak hizmet türü
  String? _selectedEmployee; // Seçilen çalışan

  // Örnek saat dilimleri (gerçek uygulamada API'dan gelecektir)
  final List<String> _timeSlots = [
    '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
  ];

  // Örnek hizmetler (gerçek uygulamada API'dan gelecektir)
  final List<Map<String, dynamic>> _availableServices = [
    {'name': 'Saç Kesimi', 'price': '150 TL', 'duration': '30 dk', 'icon': Icons.content_cut},
    {'name': 'Manikür & Pedikür', 'price': '100 TL', 'duration': '45 dk', 'icon': Icons.handyman},
    {'name': 'Cilt Bakımı', 'price': '250 TL', 'duration': '60 dk', 'icon': Icons.face},
    {'name': 'Saç Boyama', 'price': '300 TL', 'duration': '90 dk', 'icon': Icons.brush},
    {'name': 'Masaj', 'price': '200 TL', 'duration': '60 dk', 'icon': Icons.spa},
  ];

  // Örnek çalışanlar (gerçek uygulamada API'dan gelecektir)
  final List<Map<String, dynamic>> _availableEmployees = [
    {'name': 'Ayşe', 'avatarText': 'A'},
    {'name': 'Burak', 'avatarText': 'B'},
    {'name': 'Cem', 'avatarText': 'C'},
    {'name': 'Deniz', 'avatarText': 'D'},
    {'name': 'Elif', 'avatarText': 'E'},
  ];


  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    // Türkçe tarih formatlamasını yükle
    initializeDateFormatting('tr_TR', null).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _generateWeekDates() {
    _weekDates.clear();
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _weekDates.add(now.add(Duration(days: i)));
    }
    _selectedDate = _weekDates[_selectedDateIndex]; // Başlangıçta seçili günü ayarla
  }

  void _showAppointmentBookingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran boyutu için
      backgroundColor: Colors.transparent, // Arka planı şeffaf yap
      builder: (context) {
        return StatefulBuilder( // BottomSheet içindeki state'i yönetmek için
          builder: (BuildContext context, StateSetter setStateBtmSheet) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8, // Ekranın %80'i kadar yükseklik
              decoration: BoxDecoration(
                color: AppColors.backgroundColorLight, // Bottom sheet rengi
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Randevu Oluştur',
                          style: AppFonts.poppinsBold(fontSize: 20, color: AppColors.textColorDark),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.iconColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // `tr_TR` ile Türkçe ay adı kısaltmaları alınır (Oca, Şub, Mar vb.)
                            'Tarih Seçimi: ${DateFormat('dd MMM', 'tr_TR').format(_selectedDate)}',
                            style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                          ),
                          const SizedBox(height: 15),

                          // Saat Dilimi Seçimi
                          Text(
                            'Saat Seçimi:',
                            style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0, // Yatay boşluk
                            runSpacing: 8.0, // Dikey boşluk
                            children: _timeSlots.map((time) {
                              final bool isSelected = _selectedTimeSlot == time;
                              return GestureDetector(
                                onTap: () {
                                  setStateBtmSheet(() {
                                    _selectedTimeSlot = time;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.accentColor : AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.dividerColor.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    time,
                                    style: AppFonts.bodySmall(
                                      color: isSelected ? AppColors.textOnPrimary : AppColors.textColorDark,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Hizmet Türü Seçimi
                          Text(
                            'Hizmet Seçimi:',
                            style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Kaydırmayı BottomSheet'in SingleChildScrollView'una bırak
                            itemCount: _availableServices.length,
                            itemBuilder: (context, index) {
                              final service = _availableServices[index];
                              final bool isSelected = _selectedServiceType == service['name'];
                              return InkWell(
                                onTap: () {
                                  setStateBtmSheet(() {
                                    _selectedServiceType = service['name'];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryColor : AppColors.dividerColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(service['icon'], color: isSelected ? AppColors.primaryColor : AppColors.iconColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service['name'],
                                              style: AppFonts.bodyMedium(
                                                color: isSelected ? AppColors.primaryColor : AppColors.textColorDark,
                                              ),
                                            ),
                                            Text(
                                              '${service['duration']} | ${service['price']}',
                                              style: AppFonts.bodySmall(color: AppColors.textColorLight),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(Icons.check_circle, color: AppColors.primaryColor),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Yeni Çalışan Seçimi Bölümü
                          Text(
                            'Çalışan Seçimi:',
                            style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100, // Yeterli yükseklik verin
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableEmployees.length,
                              itemBuilder: (context, index) {
                                final employee = _availableEmployees[index];
                                final bool isSelected = _selectedEmployee == employee['name'];
                                return GestureDetector(
                                  onTap: () {
                                    setStateBtmSheet(() {
                                      _selectedEmployee = employee['name'];
                                    });
                                  },
                                  child: _buildEmployeeSelectionItem(
                                    employee['name'],
                                    employee['avatarText'],
                                    isSelected,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),


                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _selectedTimeSlot != null && _selectedServiceType != null && _selectedEmployee != null
                          ? () {
                        // Randevuyu kaydetme mantığı
                        final String selectedDateFormatted = DateFormat('dd MMM', 'tr_TR').format(_selectedDate); // `tr_TR` eklendi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${widget.salonName} için $selectedDateFormatted, $_selectedTimeSlot saatine $_selectedEmployee tarafından $_selectedServiceType randevusu oluşturuldu!',
                            ),
                          ),
                        );
                        Navigator.pop(context); // Bottom sheet'i kapat
                        // Burada randevu verisini bir yere kaydedebilirsin (örneğin bir provider/bloc/cubit ile)
                      }
                          : null, // Seçimler yapılana kadar butonu pasif yap
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor, // Kırmızı buton
                        foregroundColor: AppColors.textOnPrimary, // Beyaz metin
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(double.infinity, 50), // Genişliği tam yap
                      ),
                      child: Text(
                        'Randevuyu Onayla',
                        style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Arka plan resminin görünmesi için şeffaf
        elevation: 0,
        leading: IconButton(
          icon: Container( // Geri butonu için beyaz yuvarlak arkaplan
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.arrow_back, color: AppColors.primaryColor), // Okun rengi
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Container( // Favori butonu için beyaz yuvarlak arkaplan
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.favorite_border, color: AppColors.primaryColor), // Kalp rengi
            ),
            onPressed: () {
              // Favoriye ekleme/çıkarma işlemi
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Arka Plan Gradient (Bu kısım zaten iyiydi)
          Container(
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
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Resmi / Harita Önizlemesi (Üst Kısım)
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor, // Placeholder renk
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Harita görseli veya placeholder
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        child: Image.asset(
                          'lib/assets/map_placeholder.png', // Harita görseliniz
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: AppColors.backgroundColorDark,
                            child: Center(child: Text('Harita Yüklenemedi', style: AppFonts.bodyMedium(color: AppColors.textColorLight))),
                          ),
                        ),
                      ),
                      // Salon Adı ve Konum Kartı
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.salonName,
                                style: AppFonts.poppinsBold(fontSize: 20, color: AppColors.textColorDark),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: AppColors.accentColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Örnek Mah. Örnek Cad. No:123',
                                    style: AppFonts.bodySmall(color: AppColors.textColorLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.star, color: AppColors.starColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.7 (250 Yorum)',
                                    style: AppFonts.bodySmall(color: AppColors.textColorLight),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Takvim Bölümü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Takvim',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _weekDates.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = _selectedDateIndex == index;
                      final DateTime date = _weekDates[index];
                      // Gün adı (Pzt, Sal vb.) için `tr_TR` locale eklendi
                      final String dayOfWeek = DateFormat('EEE', 'tr_TR').format(date);
                      final String dayOfMonth = DateFormat('dd').format(date); // Ayın günü

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDateIndex = index;
                            _selectedDate = date; // Seçilen tarihi güncelle
                            _selectedTimeSlot = null; // Yeni gün seçildiğinde saat seçimini sıfırla
                            _selectedServiceType = null; // Yeni gün seçildiğinde hizmet seçimini sıfırla
                            _selectedEmployee = null; // Yeni gün seçildiğinde çalışan seçimini sıfırla
                          });
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentColor : AppColors.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: isSelected ? AppColors.accentColor : AppColors.dividerColor),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayOfWeek,
                                style: AppFonts.bodyMedium(
                                  // FontWeight.bold buraya uygun olmayabilir, AppFonts tanımına bağlı. Kaldırıldı.
                                  color: isSelected ? Colors.white : AppColors.textColorDark,
                                ),
                              ),
                              Text(
                                dayOfMonth,
                                style: AppFonts.poppinsBold(
                                  fontSize: 20,
                                  color: isSelected ? Colors.white : AppColors.textColorDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Randevu Al Butonu (Takvim altına eklendi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _showAppointmentBookingBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(double.infinity, 50), // Genişliği tam yap
                    ),
                    child: Text(
                      'Randevu Al',
                      style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textOnPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),


                // Hizmetler Bölümü (Bu kısım randevu al butonu ile yönlendirildi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Hizmetler',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                  ),
                ),
                const SizedBox(height: 10),
                // Hizmetler listesi için sabit yükseklikte bir alan ve kaydırma özelliği
                SizedBox(
                  height: 300, // İstediğiniz maksimum yüksekliği buraya ayarlayın (örnek: 300)
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(), // İçerik az olsa bile kaydırma etkin olsun
                    padding: EdgeInsets.zero, // _buildServiceListItem zaten kendi margin'ini aldığı için buradaki padding'i sıfırlıyoruz.
                    itemCount: _availableServices.length,
                    itemBuilder: (context, index) {
                      final service = _availableServices[index];
                      return _buildServiceListItem(
                        service['name'],
                        service['price'],
                        service['duration'],
                        service['icon'],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Galeri Bölümü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Galeri',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColorDark,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Center(
                            child: Icon(Icons.image, size: 50, color: AppColors.iconColor),
                          ),
                          // Not: Eğer gerçek resimler kullanacaksanız Image.asset satırını yorumdan çıkarın.
                          // child: Image.asset(
                          //   'lib/assets/gallery_image_$index.png',
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Müşteri Yorumları Bölümü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Müşteri Yorumları',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                  ),
                ),
                const SizedBox(height: 10),
                _buildCustomerReview('Emirhan Kaya', 'Bu salon harika! Saç kesimim mükemmel oldu.', 5),
                _buildCustomerReview('Ayşe Yılmaz', 'Manikürden çok memnun kaldım, herkese tavsiye ederim.', 4),
                const SizedBox(height: 20),

                // Sıkça Sorulan Sorular Bölümü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Sıkça Sorulan Sorular',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                  ),
                ),
                const SizedBox(height: 10),
                _buildFAQItem('Randevu nasıl alabilirim?', 'Uygulama üzerinden veya telefonla alabilirsiniz.'),
                _buildFAQItem('Hangi ödeme yöntemlerini kabul ediyorsunuz?', 'Nakit, kredi kartı ve mobil ödeme.'),
                const SizedBox(height: 20),

                // Salon Hakkında Bölümü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Salon Hakkında',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Mustafa Güzellik Salonu olarak sizlere en kaliteli hizmeti sunmak için buradayız. Saç, cilt ve tırnak bakımlarınızda uzman ekibimizle her zaman yanınızdayız. Randevu almak için hemen bize ulaşın!',
                      style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Yardımcı Widget Oluşturucu Fonksiyonlar ----

  Widget _buildServiceListItem(String title, String price, String duration, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: AppColors.iconColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textColorDark),
                ),
                const SizedBox(height: 5),
                Text(
                  '$duration | $price',
                  style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReview(String name, String comment, int stars) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accentColor,
                child: Text(name[0], style: AppFonts.poppinsBold(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textColorDark),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: AppColors.starColor,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: AppFonts.bodyMedium(color: AppColors.textColorLight),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ExpansionTile(
          title: Text(
            question,
            style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textColorDark),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                answer,
                style: AppFonts.bodyMedium(color: AppColors.textColorLight),
              ),
            ),
          ],
          collapsedIconColor: AppColors.textColorDark,
          iconColor: AppColors.accentColor,
        ),
      ),
    );
  }

  // Yeni çalışan seçimi widget'ı
  Widget _buildEmployeeSelectionItem(String name, String avatarText, bool isSelected) {
    return Container(
      width: 80, // Avatar ve isim için yeterli genişlik
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accentColor : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 30, // Avatar boyutu
              backgroundColor: isSelected ? AppColors.accentColor.withOpacity(0.2) : AppColors.cardColor,
              child: Text(
                avatarText,
                style: AppFonts.poppinsBold(
                  fontSize: 24,
                  color: isSelected ? AppColors.accentColor : AppColors.textColorDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: AppFonts.bodySmall(
              color: isSelected ? AppColors.accentColor : AppColors.textColorDark,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Uzun isimler için
          ),
        ],
      ),
    );
  }
}