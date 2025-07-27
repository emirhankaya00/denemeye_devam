// lib/view/view_models/comments_viewmodel.dart

import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart'; // Yorum Repository'sini import edin

class CommentsViewModel extends ChangeNotifier {
  final CommentRepository _commentRepository = CommentRepository();
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchComments(String salonId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _commentRepository.getCommentsForSalon(salonId);
    } catch (e) {
      _errorMessage = 'Yorumlar yüklenirken bir hata oluştu: $e';
      print(_errorMessage); // Hata ayıklama için konsola yazdır
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}