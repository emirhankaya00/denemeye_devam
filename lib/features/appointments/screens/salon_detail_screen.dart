// GEREKLİ TÜM IMPORT'LAR BURADA
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/personal_model.dart' show PersonalModel;
import 'package:denemeye_devam/models/service_model.dart' show ServiceModel;
import 'package:denemeye_devam/models/saloon_model.dart' show SaloonModel;
import 'package:denemeye_devam/models/comment_model.dart'; // Yorum modeli eklendi
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:denemeye_devam/features/appointments/screens/all_reviews_screen.dart';
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
    return ChangeNotifierProvider(
      create: (_) => SalonDetailViewModel()..fetchSalonDetails(widget.salonId),
      child: Consumer<SalonDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(context, viewModel),
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

  AppBar _buildAppBar(BuildContext context, SalonDetailViewModel viewModel) {
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final bool isCurrentlyFavorite = viewModel.salon != null
        ? favoritesViewModel.isSalonFavorite(viewModel.salon!.saloonId)
        : false;

    return AppBar(
      elevation: 8,
      toolbarHeight: 80.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.accentColor,
            ],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
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
        IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
              color: isCurrentlyFavorite
                  ? Colors.red.shade400
                  : AppColors.primaryColor,
            ),
          ),
          onPressed: () {
            if (viewModel.salon != null) {
              favoritesViewModel.toggleFavorite(
                viewModel.salon!.saloonId,
                salon: viewModel.salon,
              );
            }
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SalonDetailViewModel viewModel) {
    final salon = viewModel.salon!;

    final List<CommentModel> allComments = [
      CommentModel(
        commentId: '1',
        userId: 'user1',
        saloonId: 'salon1',
        rating: 5,
        commentText:
        'Harika bir salon! Hizmet kalitesi ve personel çok iyiydi. Kesinlikle tavsiye ederim.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      CommentModel(
        commentId: '2',
        userId: 'user2',
        saloonId: 'salon1',
        rating: 4,
        commentText:
        'Fena değil, ancak biraz daha hızlı olabilirlerdi. Genel olarak memnun kaldım.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      CommentModel(
        commentId: '3',
        userId: 'user3',
        saloonId: 'salon1',
        rating: 5,
        commentText:
        'Çok güler yüzlü ekip ve profesyonel hizmet. Saç kesimim beklediğimden çok daha iyi oldu.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
      CommentModel(
        commentId: '4',
        userId: 'user4',
        saloonId: 'salon1',
        rating: 3,
        commentText:
        'Beklentimin biraz altında kaldı. Fiyatına göre daha iyi bir deneyim beklerdim.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      CommentModel(
        commentId: '5',
        userId: 'user5',
        saloonId: 'salon1',
        rating: 2,
        commentText:
        'Hiç memnun kalmadım. Çok kalabalık ve çalışanlar ilgisizdi. Bir daha gitmem.',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now(),
      ),
    ];

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
        // AppBar'ın altından başlaması için bir boşluk bırak
        Padding(
          padding: const EdgeInsets.only(
              top: 80.0), // AppBar yüksekliği kadar boşluk
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, salon),
                const SizedBox(height: 20),
                // Takvim başlığı ve butonunu içeren satır
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Takvim'),
                      // GÜNCELLENMİŞ TAKVİM BUTONU
                      GestureDetector(
                        onTap: () => _selectDateFromPicker(context, viewModel),
                        child: Container(
                          padding: const EdgeInsets.all(
                              8.0), // Padding to make it a bit larger
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor, // Button background color
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(Icons.calendar_month,
                              color: AppColors.textOnPrimary,
                              size:
                              28), // Changed icon to calendar_month for a fuller look
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0), // HR ile aynı hizada başlasın
                  child: Divider(
                      color: AppColors.dividerColor,
                      thickness: 1), // HR eklendi
                ),
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
                // Hizmetler başlığı ve HR
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: _buildSectionTitle('Hizmetler'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: AppColors.dividerColor, thickness: 1),
                ),
                _buildServicesSection(salon.services),
                const SizedBox(height: 20),
                // Galeri başlığı ve HR
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: _buildSectionTitle('Galeri'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: AppColors.dividerColor, thickness: 1),
                ),
                _buildGallerySection(),
                const SizedBox(height: 20),
                // Müşteri Yorumları başlığı ve HR
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: _buildSectionTitle('Müşteri Yorumları'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: AppColors.dividerColor, thickness: 1),
                ),
                _buildCustomerReviewsSection(allComments),
                const SizedBox(height: 20),
                // Yorum Ekle bölümü (Başlık kaldırıldı, direkt kart başlıyor)
                _buildAddReviewSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, SaloonModel salon) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                ? Image.network(
              salon.titlePhotoUrl!,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child:
                Icon(Icons.broken_image, color: Colors.grey, size: 80),
              ),
            )
                : Image.asset(
              'assets/map_placeholder.png',
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            salon.saloonName,
            style: AppFonts.poppinsBold(
              fontSize: 24,
              color: AppColors.textColorDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            salon.saloonAddress ?? 'Adres belirtilmemiş',
            style: AppFonts.bodyMedium(color: AppColors.textColorLight),
          ),
          const SizedBox(height: 10),
          Text(
            salon.saloonDescription ?? 'Açıklama bulunmuyor.',
            style: AppFonts.bodySmall(color: AppColors.textColorLight),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.poppinsBold(
        fontSize: 18,
        color: AppColors.textColorDark,
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel viewModel) {
    // Only show the selected date or today if nothing is selected
    final DateTime displayDate = viewModel.selectedDate ?? DateTime.now();
    final List<DateTime> weekDates = [displayDate];

    // Add 6 more future days if the selected date is today or in the past to maintain 7 days
    if (displayDate.isBefore(DateTime.now()) ||
        displayDate.day == DateTime.now().day &&
            displayDate.month == DateTime.now().month &&
            displayDate.year == DateTime.now().year) {
      weekDates.addAll(List.generate(
        6,
            (i) => DateTime.now().add(Duration(days: i + 1)),
      ));
    }

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = viewModel.selectedDate?.day == date.day &&
              viewModel.selectedDate?.month == date.month &&
              viewModel.selectedDate?.year == date.year;

          return GestureDetector(
            onTap: () => viewModel.selectNewDate(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentColor : AppColors.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.dividerColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'tr_TR').format(date),
                    style: AppFonts.bodyMedium(
                      color: isSelected ? Colors.white : AppColors.textColorDark,
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(date),
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
    );
  }

  Future<void> _selectDateFromPicker(
      BuildContext context, SalonDetailViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.textOnPrimary,
              onSurface: AppColors.textColorDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.selectNewDate(picked);
    }
  }

  Widget _buildServicesSection(List<ServiceModel> services) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Bu salona ait hizmet bulunmamaktadır.',
          style: AppFonts.bodyMedium(color: AppColors.textColorLight),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.serviceName,
                  style: AppFonts.poppinsBold(
                      fontSize: 15, color: AppColors.textColorDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Süre: ${service.estimatedTime.inMinutes} dk',
                  style: AppFonts.bodySmall(color: AppColors.textColorLight),
                ),
                Text(
                  'Fiyat: ${service.basePrice} TL',
                  style: AppFonts.bodyMedium(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGallerySection() {
    final List<String> galleryImages = [
      'assets/map_placeholder.png',
      'assets/map_placeholder.png',
      'assets/map_placeholder.png',
      'assets/map_placeholder.png',
      'assets/map_placeholder.png',
    ];

    if (galleryImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Galeriye henüz resim eklenmemiştir.',
          style: AppFonts.bodyMedium(color: AppColors.textColorLight),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.width * (16 / 9) * 0.5,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.4,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                galleryImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image,
                        size: 50, color: AppColors.iconColor)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerReviewsSection(List<CommentModel> allComments) {
    if (allComments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Bu salona ait henüz yorum bulunmamaktadır.',
          style: AppFonts.bodyMedium(color: AppColors.textColorLight),
        ),
      );
    }

    final List<CommentModel> commentsToDisplay = allComments.take(2).toList();
    final bool hasMoreComments = allComments.length > 2;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: commentsToDisplay.length,
          itemBuilder: (context, index) {
            final comment = commentsToDisplay[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: AppColors.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Anonim Kullanıcı',
                          style: AppFonts.poppinsBold(
                              fontSize: 14, color: AppColors.textColorDark),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < comment.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.starColor,
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.commentText,
                      style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMMM yyyy', 'tr_TR')
                          .format(comment.createdAt),
                      style: AppFonts.bodySmall(
                          color: AppColors.textColorLight.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (hasMoreComments)
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AllReviewsScreen(allComments: allComments),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Daha Fazla Yorum Göster (${allComments.length - 2} Yorum Daha)',
                  style: AppFonts.poppinsBold(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddReviewSection() {
    final TextEditingController reviewController = TextEditingController();
    int currentRating = 0; // Kullanıcının seçeceği yıldız sayısı

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puanla ve Yorum Yap', // Yeni açıklayıcı metin eklenebilir
                style: AppFonts.poppinsBold(
                    fontSize: 18, color: AppColors.textColorDark),
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.starColor,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            currentRating = index + 1;
                          });
                        },
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Yorumunuzu buraya yazın...',
                  hintStyle: AppFonts.bodyMedium(
                      color: AppColors.textColorLight.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  filled: true,
                  fillColor: AppColors.backgroundColorLight,
                ),
                style: AppFonts.bodyMedium(color: AppColors.textColorDark),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty && currentRating > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Yorumunuz gönderildi! Puan: $currentRating, Yorum: ${reviewController.text}')),
                      );
                      reviewController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Lütfen yorumunuzu yazın ve yıldız verin.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Yorumu Gönder',
                    style: AppFonts.poppinsBold(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildSectionTitle('Saat Seçimi'),
                            ),
                            const Divider(
                                color: AppColors.dividerColor, thickness: 1),
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
                                    color:
                                    isSelected ? Colors.white : Colors.black,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildSectionTitle('Hizmet Seçimi'),
                            ),
                            const Divider(
                                color: AppColors.dividerColor, thickness: 1),
                            // GÜNCELLENMİŞ HİZMET SEÇİMİ TASARIMI
                            ...vm.salon!.services.map((service) {
                              // Tekli seçimde selectedService'ı kontrol ediyoruz
                              final isSelected = vm.selectedService?.serviceId == service.serviceId;
                              return GestureDetector(
                                onTap: () => vm.selectServiceForAppointment(service), // Tekli seçim mantığı
                                child: AnimatedContainer( // Animasyonlu geçişler için AnimatedContainer
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  margin: const EdgeInsets.only(bottom: 10.0), // Kartlar arası boşluk
                                  padding: const EdgeInsets.all(14.0), // İç boşluk
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor.withOpacity(0.15) // Seçiliyse hafif bir arka plan
                                        : AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(15), // Köşeleri daha yuvarlak
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor // Seçiliyse ana renkli kenarlık
                                          : AppColors.dividerColor, // Değilse daha hafif kenarlık
                                      width: isSelected ? 2.5 : 1.0, // Seçiliyse daha kalın kenarlık
                                    ),
                                    boxShadow: isSelected // Seçiliyse hafif bir gölge
                                        ? [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.iconColor,
                                        size: 24, // İkon boyutu
                                      ),
                                      const SizedBox(width: 15), // İkon ile metin arası boşluk
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.serviceName,
                                              style: AppFonts.poppinsBold(
                                                  fontSize: 17,
                                                  color: AppColors.textColorDark),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Süre: ${service.estimatedTime.inMinutes} dk',
                                              style: AppFonts.bodySmall(
                                                  color: AppColors.textColorLight),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${service.basePrice} TL',
                                        style: AppFonts.poppinsBold(
                                            fontSize: 16,
                                            color: AppColors.primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildSectionTitle('Çalışan Seçimi'),
                            ),
                            const Divider(
                                color: AppColors.dividerColor, thickness: 1),
                            // GÜNCELLENMİŞ ÇALIŞAN SEÇİMİ TASARIMI
                            ...vm.employees.map((employee) {
                              // Tekli seçimde selectedEmployee'ı kontrol ediyoruz
                              final isSelected = vm.selectedEmployee?.personalId == employee.personalId;
                              return GestureDetector(
                                onTap: () => vm.selectEmployeeForAppointment(employee), // Tekli seçim mantığı
                                child: AnimatedContainer( // Animasyonlu geçişler için AnimatedContainer
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor.withOpacity(0.15)
                                        : AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : AppColors.dividerColor,
                                      width: isSelected ? 2.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25, // Biraz daha büyük avatar
                                        backgroundImage: NetworkImage(
                                          employee.profileImageUrl ??
                                              'https://via.placeholder.com/150', // Varsayılan görsel
                                        ),
                                        onBackgroundImageError: (exception, stackTrace) => {},
                                        backgroundColor: AppColors.dividerColor,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${employee.name} ${employee.surname}',
                                              style: AppFonts.poppinsBold(
                                                  fontSize: 17,
                                                  color: AppColors.textColorDark),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              employee.title ?? 'Çalışan',
                                              style: AppFonts.bodySmall(
                                                  color: AppColors.textColorLight),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.iconColor,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: vm.selectedTimeSlot != null &&
                            vm.selectedService != null && // Tekli seçim kontrolü
                            vm.selectedEmployee != null // Tekli seçim kontrolü
                            ? () async {
                          try {
                            await vm.createReservation();
                            if (!context.mounted) return;
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
                            if (!context.mounted) return;
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