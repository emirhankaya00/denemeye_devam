import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // DÜZELTME: Supabase'i import etmeliyiz
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

class CommentsViewModel extends ChangeNotifier {
  // DÜZELTME: Hatanın olduğu satır.
  // Artık CommentRepository'yi oluştururken ona Supabase client'ını veriyoruz.
  final CommentRepository _commentRepository =
  CommentRepository(Supabase.instance.client);

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
      debugPrint(_errorMessage); // Hata ayıklama için konsola yazdır
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}