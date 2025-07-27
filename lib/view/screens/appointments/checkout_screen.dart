// lib/view/screens/appointments/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../data/models/selected_item.dart';
import '../../view_models/checkout_viewmodel.dart';
import '../../../data/repositories/saloon_repository.dart';

class CheckoutScreen extends StatefulWidget {
  final String saloonId;
  final DateTime date;            // SalonDetail'den gelen başlangıç tarihi
  final TimeOfDay time;           // SalonDetail'den gelen (varsayılan olabilir)
  final List<SelectedItem> items;

  const CheckoutScreen({
    super.key,
    required this.saloonId,
    required this.date,
    required this.time,
    required this.items,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late DateTime _date;          // Checkout'ta değiştirilebilir
  TimeOfDay? _time;             // Saat seçme zorunlu → başlangıçta null bırakıyoruz

  @override
  void initState() {
    super.initState();
    // Tarihi en az bugüne sabitle
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final incoming = DateTime(widget.date.year, widget.date.month, widget.date.day);
    _date = incoming.isBefore(today) ? today : incoming;

    // Kullanıcı onay ekranında saati seçecek → null başlat
    _time = null;
  }

  String get _dateLabel => DateFormat('dd.MM.yyyy', 'tr_TR').format(_date);
  String get _timeLabel =>
      _time == null ? 'Saat seçilmedi' : '${_pad(_time!.hour)}:${_pad(_time!.minute)}';

  String _pad(int n) => n.toString().padLeft(2, '0');

  /// Seçili tarih+saat gelecekte mi?
  bool get _isFutureDateTime {
    if (_time == null) return false;
    final dt = DateTime(_date.year, _date.month, _date.day, _time!.hour, _time!.minute);
    return dt.isAfter(DateTime.now());
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,                 // geçmiş tarih kapalı
      lastDate: today.add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      helpText: 'Tarih seç',
    );

    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day);
      });

      // Eğer aynı gün seçildiyse ve mevcut saat geçmişe düşüyorsa sıfırla
      if (_time != null && !_isFutureDateTime) {
        setState(() => _time = null);
        _showSnack('Seçtiğin saat geçmişte kaldı, lütfen yeniden saat seç.');
      }
    }
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final init = _time ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: init,
      helpText: 'Saat seç',
      builder: (context, child) {
        // Material 3 ile kontrastı düzelt
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Geçmişe düşmesini engelle
      final candidate =
      DateTime(_date.year, _date.month, _date.day, picked.hour, picked.minute);
      if (candidate.isAfter(now)) {
        setState(() => _time = picked);
      } else {
        _showSnack('Geçmiş saat seçilemez.');
      }
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.fold<double>(0, (a, e) => a + e.lineTotal);
    const discount = 0.0;
    final grand = (total - discount).clamp(0, double.infinity);

    final canSubmit = _time != null && _isFutureDateTime && widget.items.isNotEmpty;

    return ChangeNotifierProvider(
      create: (ctx) => CheckoutViewModel(ctx.read<SaloonRepository>()),
      child: Consumer<CheckoutViewModel>(
        builder: (context, vm, _) {
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
                // ——— Tarih & Saat kartı ————————————————————————
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_available),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tarih: $_dateLabel',
                                style: AppFonts.bodyMedium(color: AppColors.textPrimary),
                              ),
                            ),
                            TextButton(
                              onPressed: _pickDate,
                              child: const Text('Değiştir'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Saat: $_timeLabel',
                                style: AppFonts.bodyMedium(
                                  color: _time == null
                                      ? Colors.red.shade600
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _pickTime,
                              child: const Text('Saat Seç'),
                            ),
                          ],
                        ),
                        if (_time == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Onaylamadan önce saat seçmelisin.',
                                style: AppFonts.bodySmall(color: Colors.red.shade600),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ——— Seçilen hizmetler ————————————————————————
                Expanded(
                  child: widget.items.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Seçili hizmet bulunmuyor.',
                        style:
                        AppFonts.bodyMedium(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final it = widget.items[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/map_placeholder.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            it.service.serviceName,
                            style: AppFonts.poppinsBold(
                                color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            '${it.service.estimatedMinutes} Dk',
                            style: AppFonts.bodySmall(
                                color: AppColors.textSecondary),
                          ),
                          trailing: Text(
                            '₺${it.lineTotal.toStringAsFixed(0)}',
                            style: AppFonts.poppinsBold(
                                color: AppColors.textPrimary),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ——— Toplam ve Onay ————————————————————————
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
                          _row('İndirim', '-₺${discount.toStringAsFixed(0)}',
                              negative: true),
                        const SizedBox(height: 6),
                        _row('Ödenecek Tutar', '₺${grand.toStringAsFixed(0)}',
                            bold: true),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (!canSubmit || vm.isSubmitting)
                                ? null
                                : () async {
                              // Son doğrulama (güvenlik)
                              if (!_isFutureDateTime) {
                                _showSnack(
                                    'Geçmiş bir tarih/saat seçemezsin.');
                                return;
                              }
                              final ok = await vm.submit(
                                saloonId: widget.saloonId,
                                date: _date,
                                time: _time!, // null değil; canSubmit garantiliyor
                                items: widget.items,
                              );
                              if (!mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Randevu oluşturuldu. Onay bekleniyor.')),
                                );
                                Navigator.pop(context, true);
                              } else {
                                _showSnack('Randevu oluşturulamadı.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.textOnPrimary,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: vm.isSubmitting
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text('Ödemeyi Onayla',
                                style: AppFonts.poppinsBold()),
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

  Widget _row(String l, String r,
      {bool bold = false, bool negative = false}) {
    final style =
    (bold ? AppFonts.poppinsBold() : AppFonts.bodyMedium()).copyWith(
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
