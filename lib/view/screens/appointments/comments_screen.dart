// lib/view/screens/appointments/comments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/comment_model.dart';
import '../../view_models/comments_viewmodel.dart';

class CommentsScreen extends StatelessWidget {
  final String saloonId;
  const CommentsScreen({super.key, required this.saloonId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CommentsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Yorumlar',
            style: AppFonts.poppinsBold(fontSize: 20, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : vm.comments.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Text(
            'Bu salon için henüz yorum bulunmuyor.',
            style: AppFonts.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
      )
          : RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () => vm.fetchComments(saloonId),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: vm.comments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => _CommentCard(comment: vm.comments[i]),
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;
  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final userName = (comment.user != null)
        ? '${(comment.user!.name ?? '').trim()} ${(comment.user!.surname ?? '').trim()}'.trim().isEmpty
        ? 'Anonim Kullanıcı'
        : '${comment.user!.name ?? ''} ${comment.user!.surname ?? ''}'.trim()
        : 'Anonim Kullanıcı';

    final profilePhotoUrl = comment.user?.profilePhotoUrl;
    final dateStr = DateFormat('dd.MM.yyyy, HH:mm').format(comment.createdAt);

    return Card(
      color: AppColors.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                backgroundImage: (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                    ? NetworkImage(profilePhotoUrl)
                    : null,
                child: (profilePhotoUrl == null || profilePhotoUrl.isEmpty)
                    ? const Icon(Icons.person, color: AppColors.primaryColor, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(userName, style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textPrimary)),
            ]),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.starColor, size: 20),
              const SizedBox(width: 4),
              Text(comment.rating.toStringAsFixed(1),
                  style: AppFonts.bodyMedium(color: AppColors.textPrimary)),
            ]),
          ]),
          const SizedBox(height: 12),
          Text(comment.commentText, style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(dateStr,
                style: AppFonts.bodySmall(color: AppColors.textSecondary.withOpacity(0.7))),
          ),
        ]),
      ),
    );
  }
}
