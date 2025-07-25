// lib/features/appointments/screens/all_reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/comment_model.dart';

class AllReviewsScreen extends StatefulWidget {
  final List<CommentModel> allComments;

  const AllReviewsScreen({super.key, required this.allComments});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

enum SortOrder { newestToOldest, oldestToNewest, highestRated } // highestRated eklendi

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  late List<CommentModel> _displayedComments;
  SortOrder _currentSortOrder = SortOrder.newestToOldest;
  int? _selectedRatingFilter; // null means no filter

  @override
  void initState() {
    super.initState();
    _displayedComments = List.from(widget.allComments); // Orijinal yorum listesini kopyala
    _applyFiltersAndSort(); // Başlangıçta filtreleri ve sıralamayı uygula
  }

  // Arama controller'ı kaldırıldığı için dispose metodundan da kaldırıldı.
  @override
  void dispose() {
    super.dispose();
  }

  // Yorumları filtreleyen ve sıralayan ana metod
  void _applyFiltersAndSort() {
    setState(() {
      List<CommentModel> tempComments = List.from(widget.allComments); // Her zaman orijinal listeden başla

      // 1. Derecelendirme Filtresi
      if (_selectedRatingFilter != null) {
        tempComments = tempComments
            .where((comment) => comment.rating == _selectedRatingFilter)
            .toList();
      }

      // 2. Sıralama
      if (_currentSortOrder == SortOrder.newestToOldest) {
        tempComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_currentSortOrder == SortOrder.oldestToNewest) {
        tempComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else if (_currentSortOrder == SortOrder.highestRated) {
        tempComments.sort((a, b) => b.rating.compareTo(a.rating));
      }

      _displayedComments = tempComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tüm Yorumlar', style: AppFonts.poppinsBold(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 8, // RootScreen AppBar ile tutarlılık için elevation artırıldı
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
      ),
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
        child: Column(
          children: [
            // Arama çubuğu kaldırıldı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sıralama Seçenekleri
                  DropdownButton<SortOrder>(
                    value: _currentSortOrder,
                    onChanged: (SortOrder? newValue) {
                      setState(() {
                        _currentSortOrder = newValue!;
                        _applyFiltersAndSort(); // Filtreleri ve sıralamayı yeniden uygula
                      });
                    },
                    items: const <DropdownMenuItem<SortOrder>>[
                      DropdownMenuItem<SortOrder>(
                        value: SortOrder.newestToOldest,
                        child: Text('En Yeniye Göre'),
                      ),
                      DropdownMenuItem<SortOrder>(
                        value: SortOrder.oldestToNewest,
                        child: Text('En Eskiye Göre'),
                      ),
                      DropdownMenuItem<SortOrder>(
                        value: SortOrder.highestRated,
                        child: Text('En Yüksek Puana Göre'),
                      ),
                    ],
                    style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                    dropdownColor: AppColors.cardColor,
                    underline: Container(), // Alt çizgiyi kaldır
                    icon: Icon(Icons.sort, color: AppColors.primaryColor),
                  ),
                  // Filtreleme Seçenekleri (Yıldız Sayısına Göre)
                  DropdownButton<int>(
                    value: _selectedRatingFilter,
                    hint: Text('Yıldıza Göre Filtrele', style: AppFonts.bodyMedium(color: AppColors.textColorLight)),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedRatingFilter = newValue;
                        _applyFiltersAndSort(); // Filtreleri ve sıralamayı yeniden uygula
                      });
                    },
                    items: <DropdownMenuItem<int>>[
                      const DropdownMenuItem<int>(
                        value: null, // Tüm yıldızları göster
                        child: Text('Tüm Yıldızlar'),
                      ),
                      for (int i = 5; i >= 1; i--)
                        DropdownMenuItem<int>(
                          value: i,
                          child: Row(
                            children: List.generate(i, (index) => Icon(Icons.star, size: 18, color: AppColors.starColor)),
                          ),
                        ),
                    ],
                    style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                    dropdownColor: AppColors.cardColor,
                    underline: Container(),
                    icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _displayedComments.isEmpty
                  ? Center(
                child: Text(
                  'Gösterilecek yorum bulunamadı.',
                  style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _displayedComments.length,
                itemBuilder: (context, index) {
                  final comment = _displayedComments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                'Anonim Kullanıcı', // Gerçek kullanıcı adı gelince değiştirilebilir
                                style: AppFonts.poppinsBold(fontSize: 14, color: AppColors.textColorDark),
                              ),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < comment.rating ? Icons.star : Icons.star_border,
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
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(comment.createdAt),
                            style: AppFonts.bodySmall(color: AppColors.textColorLight.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}