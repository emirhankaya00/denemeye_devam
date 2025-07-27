import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

import '../../view_models/filter_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';
import '../../../data/repositories/saloon_repository.dart';
import '../../../data/models/saloon_model.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});



  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final Map<String, SaloonModel> _hydrated = {};
  bool _isEnriching = false;

  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  FilterViewModel? _vm; // listener için referans
  int _lastListHash = 0; // listedeki değişimi anlamak için

  @override
  void initState() {
    super.initState();
    // VM güncellenince detayları tamamla
    // (listener'ı didChangeDependencies'te bağlayacağız çünkü context orada hazır)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<FilterViewModel>();
    if (_vm != vm) {
      _vm?.removeListener(_onVmChanged);
      _vm = vm;
      _vm?.addListener(_onVmChanged);
    }
  }

  @override
  void dispose() {
    _vm?.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() {
    // VM tarafında filteredSaloons değiştiyse zenginleştirmeyi tetikle
    final vm = _vm;
    if (vm == null) return;
    final hash = _calcListHash(vm);
    if (hash != _lastListHash) {
      _lastListHash = hash;
      _hydrateMissing(); // değişim algılandı → detayları çek
    }
  }

  int _calcListHash(FilterViewModel vm) =>
      Object.hashAll(vm.filteredSaloons.map((e) => e.saloonId));

  Future<void> _hydrateMissing() async {
    final vm = context.read<FilterViewModel>();
    if (vm.filteredSaloons.isEmpty || _isEnriching) return;

    final repo = context.read<SaloonRepository>();
    final need = vm.filteredSaloons.where((s) {
      final validId = s.saloonId.isNotEmpty && _uuidRegExp.hasMatch(s.saloonId);
      if (!validId) return false; // geçersiz ID'leri atla
      final noName = (s.saloonName == null || s.saloonName!.trim().isEmpty);
      final noImage = (s.titlePhotoUrl == null || s.titlePhotoUrl!.trim().isEmpty);
      final noServices = (s.services == null || s.services!.isEmpty);
      final noRating = (s.rating == null);
      return noName || noImage || noServices || noRating;
    }).toList();

    if (need.isEmpty) return;

    setState(() => _isEnriching = true);
    try {
      for (final s in need) {
        if (_hydrated.containsKey(s.saloonId)) continue;
        final full = await repo.getSaloonById(s.saloonId);
        if (full != null && mounted) {
          setState(() => _hydrated[s.saloonId] = full);
        }
      }
    } finally {
      if (mounted) setState(() => _isEnriching = false);
    }
  }

  Future<void> _refresh() async {
    final vm = context.read<FilterViewModel>();
    await vm.applyFiltersAndFetchResults(vm.currentFilters);
    if (mounted) {
      setState(() {
        _hydrated.clear();
        _lastListHash = 0;
      });
    }
    await _hydrateMissing();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();

    // VM yükleme bitti, sonuç var ve henüz hydrate edilmemişse garantiye al
    if (!vm.isLoading && vm.filteredSaloons.isNotEmpty && !_isEnriching) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateMissing());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Filtre Sonuçları',
            style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_isEnriching)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(FilterViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (vm.filteredSaloons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Bu kriterlere uyan salon bulunamadı.',
            style: AppFonts.poppinsHeaderTitle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.filteredSaloons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final raw = vm.filteredSaloons[i];
          final s = _hydrated[raw.saloonId] ?? raw;

          final name = (s.saloonName == null || s.saloonName!.trim().isEmpty)
              ? 'İsimsiz Salon'
              : s.saloonName!;
          final desc = s.saloonDescription?.trim().isNotEmpty == true
              ? s.saloonDescription!
              : 'Açıklama mevcut değil.';
          final location =
          (s.saloonAddress ?? '').split(',').first.trim().isEmpty
              ? 'Konum Yok'
              : (s.saloonAddress ?? '').split(',').first.trim();

          final serviceNames = (s.services ?? [])
              .map((x) => x.serviceName)
              .where((e) => e != null && e!.trim().isNotEmpty)
              .map((e) => e!)
              .toList();
          final servicesForCard =
          serviceNames.isNotEmpty ? serviceNames : ['Hizmet Yok'];

          final ratingForCard = s.rating ?? 0.0;

          return SalonCard(
            salonId: s.saloonId,
            name: name,
            description: desc,
            rating: ratingForCard,
            location: location,
            distance: '5 Km',
            services: servicesForCard,
            imagePath: s.titlePhotoUrl,
          );
        },
      ),
    );
  }
}
