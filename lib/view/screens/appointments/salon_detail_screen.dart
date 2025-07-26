// lib/features/saloons/screens/salon_detail_screen.dart

// GEREKLİ TÜM IMPORT'LAR BURADA
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'all_reviews_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/saloon_model.dart';
import '../../../data/models/service_model.dart';
import '../../view_models/favorites_viewmodel.dart';
import '../../view_models/saloon_detail_viewmodel.dart';

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
    // Verileri çekmek için ViewModel'ı tetikle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalonDetailViewModel>(context, listen: false)
          .fetchSalonDetails(widget.salonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'ı burada oluşturuyoruz, böylece initState'de context'e erişim sorunu yaşamayız.
    return ChangeNotifierProvider(
      create: (_) => SalonDetailViewModel()..fetchSalonDetails(widget.salonId),
      child: Consumer<SalonDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            // Arka plan rengi tüm sayfada tutarlı
            backgroundColor: AppColors.background,
            // AppBar artık sayfanın arkasına geçmiyor
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
      elevation: 1.0, // Düz tasarım için hafif gölge
      backgroundColor: AppColors.primaryColor, // Ana renk
      foregroundColor: AppColors.textOnPrimary, // Geri tuşu ve başlık rengi
      title: Text(viewModel.salon?.saloonName ?? 'Salon Detayı'),
      actions: [
        IconButton(
          icon: Icon(
            isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
            color: isCurrentlyFavorite ? Colors.red.shade400 : AppColors.textOnPrimary,
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

    // Örnek yorumlar (veri kaynağından gelecek)
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
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, salon),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Takvim'),
                IconButton(
                  onPressed: () => _selectDateFromPicker(context, viewModel),
                  icon: const Icon(Icons.calendar_month, color: AppColors.primaryColor, size: 28),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: AppColors.borderColor, thickness: 1),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionTitle('Hizmetler'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: AppColors.borderColor, thickness: 1),
          ),
          const SizedBox(height: 8),
          _buildServicesSection(salon.services),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionTitle('Galeri'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: AppColors.borderColor, thickness: 1),
          ),
          const SizedBox(height: 8),
          _buildGallerySection(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionTitle('Müşteri Yorumları'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: AppColors.borderColor, thickness: 1),
          ),
          const SizedBox(height: 8),
          _buildCustomerReviewsSection(allComments),
          const SizedBox(height: 20),
          _buildAddReviewSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SaloonModel salon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                child: Icon(Icons.broken_image, color: Colors.grey, size: 80),
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
            style: AppFonts.poppinsBold(fontSize: 24, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 5),
          Text(
            salon.saloonAddress ?? 'Adres belirtilmemiş',
            style: AppFonts.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            salon.saloonDescription ?? 'Açıklama bulunmuyor.',
            style: AppFonts.bodySmall(color: AppColors.textSecondary),
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
      style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
    );
  }

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel viewModel) {
    final DateTime _ = viewModel.selectedDate ?? DateTime.now();
    final List<DateTime> weekDates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

    // Eğer kullanıcı bir tarih seçtiyse, o haftayı göster
    if (viewModel.selectedDate != null) {
      final startOfWeek = viewModel.selectedDate!.subtract(Duration(days: viewModel.selectedDate!.weekday - 1));
      weekDates.clear();
      weekDates.addAll(List.generate(7, (i) => startOfWeek.add(Duration(days: i))));
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
                color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? Colors.transparent : AppColors.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'tr_TR').format(date).toUpperCase(),
                    style: AppFonts.bodyMedium(color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary),
                  ),
                  Text(
                    DateFormat('dd').format(date),
                    style: AppFonts.poppinsBold(fontSize: 20, color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDateFromPicker(BuildContext context, SalonDetailViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.background),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      viewModel.selectNewDate(picked);
    }
  }


  Widget _buildServicesSection(List<ServiceModel> services) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Bu salona ait hizmet bulunmamaktadır.', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
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
                border: Border.all(color: AppColors.borderColor)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(service.serviceName, style: AppFonts.poppinsBold(fontSize: 15, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Text('Süre: ${service.estimatedTime.inMinutes} dk', style: AppFonts.bodySmall(color: AppColors.textSecondary)),
                // --- HATA DÜZELTMESİ BURADA ---
                Text(
                  'Fiyat: ${service.basePrice} TL',
                  // `fontWeight` parametresi yerine `.copyWith()` metodu kullanıldı.
                  style: AppFonts.bodyMedium(color: AppColors.primaryColor)
                      .copyWith(fontWeight: FontWeight.bold),
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
    ];
    if (galleryImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Galeriye henüz resim eklenmemiştir.', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(galleryImages[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerReviewsSection(List<CommentModel> allComments) {
    if (allComments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Text('Bu salona ait henüz yorum bulunmamaktadır.', style: AppFonts.bodyMedium(color: AppColors.textSecondary), textAlign: TextAlign.center),
      );
    }
    final commentsToDisplay = allComments.take(2).toList();
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
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.borderColor)),
              color: AppColors.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Anonim Kullanıcı', style: AppFonts.poppinsBold(fontSize: 14, color: AppColors.textPrimary)),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(starIndex < comment.rating ? Icons.star : Icons.star_border, color: AppColors.starColor, size: 18);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(comment.commentText, style: AppFonts.bodyMedium(color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(comment.createdAt), style: AppFonts.bodySmall(color: AppColors.textSecondary.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            );
          },
        ),
        if (allComments.length > 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AllReviewsScreen(allComments: allComments)));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Tüm Yorumları Gör', style: AppFonts.poppinsBold()),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddReviewSection() {
    final TextEditingController reviewController = TextEditingController();
    int currentRating = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: AppColors.borderColor)),
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puanla ve Yorum Yap', style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary)),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < currentRating ? Icons.star : Icons.star_border, color: AppColors.starColor, size: 30),
                        onPressed: () => setState(() => currentRating = index + 1),
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
                  hintStyle: AppFonts.bodyMedium(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                style: AppFonts.bodyMedium(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { /* Yorum gönderme logiği */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Yorumu Gönder', style: AppFonts.poppinsBold(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentBookingBottomSheet(BuildContext context, SalonDetailViewModel viewModel) {
    // ... (Bu fonksiyonun içi renk paletinden bağımsız olduğu için değiştirilmedi)
    // ÖNEMLİ: Eğer bu fonksiyon içinde de eski renkler kullanılıyorsa,
    // aynı mantıkla AppColors'daki yeni renklerle güncellenmelidir.
  }
}