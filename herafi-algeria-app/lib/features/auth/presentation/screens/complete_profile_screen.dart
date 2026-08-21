import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/data/algeria_locations.dart';
import '../../../../core/constants/categories.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../services/current_user_provider.dart';
import '../../../home/presentation/screens/main_shell.dart';
import '../../../profile/presentation/widgets/work_photos_section.dart';
import '../widgets/multi_select_specialties.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final UserRole role;
  final CraftsmanType? craftsmanType;

  /// إن كانت true تعمل الشاشة كوضع تعديل لحساب مكتمل موجود أصلًا
  final bool editMode;

  const CompleteProfileScreen({
    super.key,
    required this.role,
    this.craftsmanType,
    this.editMode = false,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _priceNoteController = TextEditingController();

  String? _selectedWilaya;
  String? _selectedCommune;
  int? _yearsExperience;
  final Set<String> _selectedSpecialties = {};
  final List<String> _workPhotoUrls = [];
  bool _isLoading = false;

  final List<String> _wilayas = getWilayaNames();

  bool get _isCraftsman =>
      widget.role == UserRole.craftsman ||
      widget.role == UserRole.company ||
      widget.role == UserRole.group;

  bool get _isEditMode {
    // وضع تعديل حقيقي: ملف مكتمل موجود أصلًا — حتى لو لم يُمرَّر editMode صراحة
    final existing = ref.read(currentUserProvider).valueOrNull;
    return widget.editMode ||
        (existing != null &&
            existing.fullName != null &&
            existing.fullName!.isNotEmpty &&
            existing.wilaya != null);
  }

  @override
  void initState() {
    super.initState();
    final existing = ref.read(currentUserProvider).valueOrNull;
    if (existing != null) {
      _nameController.text = existing.fullName ?? '';
      _bioController.text = existing.bio ?? '';
      _priceNoteController.text = existing.priceNote ?? '';
      _selectedWilaya = existing.wilaya;
      _selectedCommune = existing.commune;
      _yearsExperience = existing.yearsOfExperience;
      _selectedSpecialties.addAll(existing.specialties);
      _workPhotoUrls.addAll(existing.workPhotos);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectWilayaFirst)),
      );
      return;
    }
    if (_isCraftsman && _selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectSpecialtyAtLeastOne)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final existing = ref.read(currentUserProvider).valueOrNull;

      final uid = existing?.uid ?? authService.currentUid;
      if (uid == null) {
        throw Exception(l10n.loginFirst);
      }
      final phone =
          existing?.phone ?? authService.firebaseUser?.phoneNumber ?? '';

      final updatedUser = UserModel(
        uid: uid,
        phone: phone,
        fullName: _nameController.text.trim(),
        role: widget.role,
        craftsmanType: widget.craftsmanType,
        wilaya: _selectedWilaya,
        commune: _selectedCommune,
        specialties: _selectedSpecialties.toList(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        priceNote: _priceNoteController.text.trim().isEmpty
            ? null
            : _priceNoteController.text.trim(),
        yearsOfExperience: _yearsExperience,
        workPhotos: _workPhotoUrls,
        isVerified: existing?.isVerified ?? true,
        isActive: existing?.isActive ?? true,
        rating: existing?.rating ?? 0,
        ratingCount: existing?.ratingCount ?? 0,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await authService.updateProfile(updatedUser);
      await ref.read(currentUserProvider.notifier).setUser(updatedUser);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_isEditMode) {
        // وضع التعديل: نعود للشاشة السابقة بدل إعادة بناء الواجهة الرئيسية
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.editProfileSaved),
          backgroundColor: AppColors.success,
        ));
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSaveFailed(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _priceNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = _isEditMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editProfile : l10n.completeProfile),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primarySurface,
                  child: Icon(
                    _isCraftsman
                        ? Icons.handyman_rounded
                        : Icons.person_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (isEdit)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    l10n.editProfileHint,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.nameRequired
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedWilaya,
                decoration: InputDecoration(
                  labelText: l10n.wilaya,
                  prefixIcon: const Icon(Icons.location_city_rounded),
                ),
                items: _wilayas
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedWilaya = v;
                  _selectedCommune = null;
                }),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCommune,
                decoration: InputDecoration(
                  labelText: l10n.commune,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                items: _selectedWilaya != null
                    ? getCommunesForWilaya(_selectedWilaya!)
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList()
                    : [],
                onChanged: (v) => setState(() => _selectedCommune = v),
              ),
              if (_isCraftsman) ...[
                const SizedBox(height: 20),
                Text('${l10n.specialties} *',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                MultiSelectSpecialties(
                  initialSelected: _selectedSpecialties,
                  onChanged: (selected) {
                    setState(() {
                      _selectedSpecialties.clear();
                      _selectedSpecialties.addAll(selected);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.bioOptional,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceNoteController,
                  decoration: InputDecoration(
                    labelText: l10n.priceNoteOptional,
                    hintText: l10n.priceNoteHint,
                    prefixIcon: const Icon(Icons.price_change_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _yearsExperience,
                  decoration: InputDecoration(
                    labelText: l10n.yearsOfExperience,
                    prefixIcon: const Icon(Icons.work_history_outlined),
                  ),
                  items: List.generate(40, (i) => i + 1)
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y سنة'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _yearsExperience = v),
                ),
                const SizedBox(height: 20),
                WorkPhotosSection(
                  currentUrls: _workPhotoUrls,
                  onChanged: (urls) => setState(() => _workPhotoUrls
                    ..clear()
                    ..addAll(urls)),
                ),
              ],
              const SizedBox(height: 28),
              AppButton(
                label: isEdit ? l10n.saveEdits : l10n.saveAndContinue,
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
