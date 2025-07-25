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

enum SortOrder { newestToOldest, oldestToNewest, highestRated }

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  late List<CommentModel> _displayedComments;
  SortOrder _currentSortOrder = SortOrder.newestToOldest;
  int? _selectedRatingFilter;

  @override
  void initState() {
    super.initState();
    _displayedComments = List.from(widget.allComments);
    _applyFiltersAndSort();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFiltersAndSort() {
    setState(() {
      List<CommentModel> tempComments = List.from(widget.allComments);

      if (_selectedRatingFilter != null) {
        tempComments = tempComments
            .where((comment) => comment.rating == _selectedRatingFilter)
            .toList();
      }

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
      // 1. Arka plan rengi güncellendi
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // 2. AppBar başlık ve ikon renkleri güncellendi
        title: Text('Tüm Yorumlar', style: AppFonts.poppinsBold(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primaryColor, // 3. Ana renk kullanıldı
        foregroundColor: AppColors.textOnPrimary, // Geri butonu için
        elevation: 1.0, // Düz tasarım için gölge azaltıldı
        // Eski gradient ve şekil kaldırıldı.
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<SortOrder>(
                  value: _currentSortOrder,
                  onChanged: (SortOrder? newValue) {
                    setState(() {
                      _currentSortOrder = newValue!;
                      _applyFiltersAndSort();
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
                  // 4. Dropdown metin ve ikon renkleri güncellendi
                  style: AppFonts.bodyMedium(color: AppColors.textPrimary),
                  dropdownColor: AppColors.cardColor,
                  underline: Container(),
                  icon: const Icon(Icons.sort, color: AppColors.primaryColor),
                ),
                DropdownButton<int>(
                  value: _selectedRatingFilter,
                  hint: Text('Yıldıza Göre Filtrele', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedRatingFilter = newValue;
                      _applyFiltersAndSort();
                    });
                  },
                  items: <DropdownMenuItem<int>>[
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Tüm Yıldızlar'),
                    ),
                    for (int i = 5; i >= 1; i--)
                      DropdownMenuItem<int>(
                        value: i,
                        child: Row(
                          children: List.generate(i, (index) => const Icon(Icons.star, size: 18, color: AppColors.starColor)),
                        ),
                      ),
                  ],
                  // 5. Diğer dropdown renkleri de güncellendi
                  style: AppFonts.bodyMedium(color: AppColors.textPrimary),
                  dropdownColor: AppColors.cardColor,
                  underline: Container(),
                  icon: const Icon(Icons.filter_list, color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor), // Yeni kenarlık rengi kullanıldı
          Expanded(
            child: _displayedComments.isEmpty
                ? Center(
              child: Text(
                'Gösterilecek yorum bulunamadı.',
                // 6. Boş liste metin rengi güncellendi
                style: AppFonts.bodyMedium(color: AppColors.textSecondary),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayedComments.length,
              itemBuilder: (context, index) {
                final comment = _displayedComments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.05),
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
                              'Anonim Kullanıcı',
                              // 7. Kart içindeki ana metin rengi güncellendi
                              style: AppFonts.poppinsBold(fontSize: 14, color: AppColors.textPrimary),
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
                        const SizedBox(height: 12),
                        Text(
                          comment.commentText,
                          // 8. Kart içindeki ikincil metin rengi güncellendi
                          style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat('dd.MM.yyyy, HH:mm').format(comment.createdAt),
                            // 9. Tarih metin rengi güncellendi
                            style: AppFonts.bodySmall(color: AppColors.textSecondary.withOpacity(0.7)),
                          ),
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
    );
  }
}