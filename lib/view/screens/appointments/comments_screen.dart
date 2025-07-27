// lib/view/screens/comments/comments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/comment_model.dart';
import '../../view_models/comments_viewmodel.dart';

class CommentsScreen extends StatefulWidget {
  final String salonId;
  const CommentsScreen({super.key, required this.salonId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentsViewModel>(context, listen: false).fetchComments(widget.salonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentsViewModel(),
      child: Consumer<CommentsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                'Yorumlar',
                style: AppFonts.poppinsBold(fontSize: 20, color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : viewModel.comments.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Text(
                  'Bu salon için henüz yorum bulunmuyor.',
                  style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: viewModel.comments.length,
              itemBuilder: (context, index) {
                final comment = viewModel.comments[index];
                return _buildCommentCard(comment);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment) {
    // Kullanıcı adını ve soyadını birleştir, yoksa 'Anonim Kullanıcı' de.
    final String userName = comment.user != null
        ? '${comment.user!.name} ${comment.user!.surname}'.trim()
        : 'Anonim Kullanıcı';

    // Profil fotoğrafı URL'si varsa kullan, yoksa varsayılan ikon.
    final String? profilePhotoUrl = comment.user?.profilePhotoUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( // Profil resmi ve kullanıcı adı için Row
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      backgroundImage: profilePhotoUrl != null && profilePhotoUrl.isNotEmpty
                          ? NetworkImage(profilePhotoUrl) as ImageProvider<Object>?
                          : null, // If profilePhotoUrl is null or empty, NetworkImage is null
                      child: profilePhotoUrl == null || profilePhotoUrl.isEmpty
                          ? Icon(Icons.person, color: AppColors.primaryColor, size: 24)
                          : null, // If NetworkImage is used, child is null
                    ),
                    const SizedBox(width: 12),
                    Text(
                      userName,
                      style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.starColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      comment.rating.toStringAsFixed(1),
                      style: AppFonts.bodyMedium(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.commentText,
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('dd.MM.yyyy, HH:mm').format(comment.createdAt), // Tarih formatı
                style: AppFonts.bodySmall(color: AppColors.textSecondary.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}