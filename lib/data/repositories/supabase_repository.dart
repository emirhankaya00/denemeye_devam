// lib/data/repositories/supabase_repository.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

// GEREKSİZ IMPORT SATIRI KALDIRILDI
var logger = Logger();

class SupabaseRepository {
  final supabase = Supabase.instance.client;

  Future<void> uploadSalonImageAndUpdate(String salonId) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imageFile == null) {
      return;
    }

    try {
      final file = File(imageFile.path);
      final fileName = '${const Uuid().v4()}.${imageFile.path.split('.').last}';
      final filePath = '$salonId/$fileName';

      await supabase.storage.from('salon-images').upload(filePath, file);

      final imageUrl =
      supabase.storage.from('salon-images').getPublicUrl(filePath);

      await supabase
          .from('saloons')
          .update({'title_photo_url': imageUrl}).eq('saloon_id', salonId);

      logger.i('Resim başarıyla yüklendi ve URL veritabanına kaydedildi!');
    } catch (e) {
      logger.i('Hata oluştu: $e');
    }
  }
}