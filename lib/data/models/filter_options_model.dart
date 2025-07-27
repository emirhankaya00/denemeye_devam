import 'package:flutter/foundation.dart';

/// Kullanıcının filtre popup'ında yaptığı seçimleri temsil eden,
/// basit bir veri modelidir.
///
/// Bu sınıf, seçilen minimum puanı ve hizmetleri tek bir pakette toplayarak
/// ViewModel'den Repository'ye kolayca aktarılmasını sağlar.
@immutable
class FilterOptions {
  /// Kullanıcının seçtiği minimum yıldız sayısı.
  /// Örneğin, 3.0 seçilirse, sadece 3 yıldız ve üzeri salonlar gösterilir.
  final double minRating;

  /// Kullanıcının seçtiği hizmetlerin isim listesi.
  /// Örneğin, ['Saç Kesimi', 'Manikür'].
  final List<String> selectedServices;

  /// FilterOptions nesnesi oluşturur.
  const FilterOptions({
    this.minRating = 0.0, // Varsayılan olarak minimum puan filtresi yok.
    this.selectedServices = const [], // Varsayılan olarak seçili hizmet yok.
  });

  /// Bu, mevcut seçenekleri değiştirmeden yeni bir kopya oluşturmak için kullanışlıdır.
  /// Örneğin, sadece rating'i güncellemek için: `currentOptions.copyWith(minRating: 4.0)`
  FilterOptions copyWith({
    double? minRating,
    List<String>? selectedServices,
  }) {
    return FilterOptions(
      minRating: minRating ?? this.minRating,
      selectedServices: selectedServices ?? this.selectedServices,
    );
  }
}