import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/selected_item.dart';
import '../../view_models/checkout_viewmodel.dart';
import '../../../data/repositories/saloon_repository.dart';

class CheckoutScreen extends StatelessWidget {
  final String saloonId;          // ← ÇİFT “o”
  final DateTime date;
  final TimeOfDay time;
  final List<SelectedItem> items;

  const CheckoutScreen({
    super.key,
    required this.saloonId,
    required this.date,
    required this.time,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd.MM.yyyy').format(date);
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return ChangeNotifierProvider(
      create: (ctx) => CheckoutViewModel(ctx.read<SaloonRepository>()),
      child: Consumer<CheckoutViewModel>(
        builder: (context, vm, _) {
          final total = items.fold<double>(0, (a, e) => a + e.lineTotal);
          const discount = 0.0; // İstersen sahte kuponu 10.0 yap
          final grand = (total - discount).clamp(0, double.infinity);

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text('Ödeme', style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
              backgroundColor: AppColors.background,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            body: Column(
              children: [
                // Randevu özeti
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Randevu: $dateLabel • $timeLabel',
                            style: AppFonts.bodyMedium(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Seçilen hizmetler listesi
                Expanded(
                  child: items.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Seçili hizmet bulunmuyor.',
                        style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/map_placeholder.png',
                                width: 56, height: 56, fit: BoxFit.cover),
                          ),
                          title: Text(
                            it.service.serviceName,
                            style: AppFonts.poppinsBold(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            '${it.service.estimatedMinutes} Dk',
                            style: AppFonts.bodySmall(color: AppColors.textSecondary),
                          ),
                          trailing: Text(
                            '₺${it.lineTotal.toStringAsFixed(0)}',
                            style: AppFonts.poppinsBold(color: AppColors.textPrimary),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Toplamlar + Onayla
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _row('Hizmet Toplamı', '₺${total.toStringAsFixed(0)}'),
                        if (discount > 0)
                          _row('İndirim', '-₺${discount.toStringAsFixed(0)}', negative: true),
                        const SizedBox(height: 6),
                        _row('Ödenecek Tutar', '₺${grand.toStringAsFixed(0)}', bold: true),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.isSubmitting || items.isEmpty
                                ? null
                                : () async {
                              final ok = await vm.submit(
                                saloonId: saloonId, // ← çift “o”
                                date: date,
                                time: time,
                                items: items,
                              );
                              if (!context.mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Randevu oluşturuldu. Onay bekleniyor.')),
                                );
                                Navigator.pop(context, true); // başarıyla dön
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Randevu oluşturulamadı.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: vm.isSubmitting
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Text('Ödemeyi Onayla', style: AppFonts.poppinsBold()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String l, String r, {bool bold = false, bool negative = false}) {
    final style = (bold ? AppFonts.poppinsBold() : AppFonts.bodyMedium()).copyWith(
      color: negative ? Colors.red : AppColors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(l, style: style), Text(r, style: style)],
      ),
    );
  }
}
