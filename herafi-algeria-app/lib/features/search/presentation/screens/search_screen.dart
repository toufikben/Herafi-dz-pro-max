import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/data/algeria_locations.dart';
import '../../../../core/widgets/craftsman_card.dart';
import '../../../../models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../services/user_service.dart';
import '../../../craftsman/presentation/screens/craftsman_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;

  const SearchScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedWilaya;
  String? _selectedCommune;
  String? _selectedCategoryId;
  double _minRating = 0.0;
  bool _isLoading = false;
  bool _searched = false;
  List<UserModel> _results = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _searched = true;
    });

    try {
      final results = await ref.read(userServiceProvider).searchCraftsmen(
            wilaya: _selectedWilaya,
            commune: _selectedCommune,
            minRating: _minRating,
            categoryId: _selectedCategoryId,
            query: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
          );
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في البحث: $e')),
        );
      }
    }
  }

  String _specialtyName(UserModel u) {
    if (u.specialties.isEmpty) return 'حرفة عامة';
    final cat = kCraftCategories.where((c) => c.id == u.specialties.first);
    return cat.isNotEmpty ? cat.first.nameAr : u.specialties.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        title: Text(
          l10n.search,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن اسم، بناء، صباغ، ...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                    filled: true,
                    fillColor: AppColors.darkBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                
                // Categories (Circular Icons)
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kCraftCategories.length,
                    itemBuilder: (context, index) {
                      final cat = kCraftCategories[index];
                      final isSelected = _selectedCategoryId == cat.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = isSelected ? null : cat.id;
                          });
                          _performSearch();
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(left: 12),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.secondary 
                                      : AppColors.darkBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.secondary 
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ] : null,
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: isSelected ? Colors.white : AppColors.secondary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.nameAr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Location & Rating Filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        icon: Icons.location_on_rounded,
                        label: _selectedWilaya ?? 'جميع الولايات',
                        onTap: _showWilayaPicker,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        icon: Icons.star_rounded,
                        label: _minRating == 0 ? 'الأعلى تقييماً' : 'تقييم +${_minRating.toInt()}',
                        onTap: _showRatingPicker,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results Count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'دليل الحرفيين',
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_results.length} حرفي',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          
          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
                : _results.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          return CraftsmanCard(
                            user: _results[index],
                            specialty: _specialtyName(_results[index]),
                            onTap: () => _navigateToDetail(_results[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            'لم نجد حرفيين طابقوا خيارات البحث الحالية',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedWilaya = null;
                _selectedCommune = null;
                _selectedCategoryId = null;
                _minRating = 0.0;
                _searchController.clear();
              });
              _performSearch();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة ضبط التصفية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSurface,
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWilayaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('اختر الولاية', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: kAlgeriaWilayas.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('جميع الولايات', style: TextStyle(color: Colors.white70)),
                      onTap: () {
                        setState(() {
                          _selectedWilaya = null;
                          _selectedCommune = null;
                        });
                        Navigator.pop(context);
                        _performSearch();
                      },
                    );
                  }
                  final w = kAlgeriaWilayas[index - 1];
                  return ListTile(
                    title: Text(w.nameAr, style: const TextStyle(color: Colors.white)),
                    trailing: _selectedWilaya == w.nameAr ? const Icon(Icons.check_circle, color: AppColors.secondary) : null,
                    onTap: () {
                      setState(() => _selectedWilaya = w.nameAr);
                      Navigator.pop(context);
                      _showCommunePicker(w);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCommunePicker(Wilaya wilaya) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('بلديات ${wilaya.nameAr}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: wilaya.communes.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('جميع البلديات', style: TextStyle(color: Colors.white70)),
                      onTap: () {
                        setState(() => _selectedCommune = null);
                        Navigator.pop(context);
                        _performSearch();
                      },
                    );
                  }
                  final c = wilaya.communes[index - 1];
                  return ListTile(
                    title: Text(c, style: const TextStyle(color: Colors.white)),
                    trailing: _selectedCommune == c ? const Icon(Icons.check_circle, color: AppColors.secondary) : null,
                    onTap: () {
                      setState(() => _selectedCommune = c);
                      Navigator.pop(context);
                      _performSearch();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('الحد الأدنى للتقييم', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [0, 3, 4, 4.5].map((r) {
                  final isSelected = _minRating == r.toDouble();
                  return GestureDetector(
                    onTap: () {
                      setState(() => _minRating = r.toDouble());
                      Navigator.pop(context);
                      _performSearch();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.secondary : Colors.white12),
                      ),
                      child: Text(
                        r == 0 ? 'الكل' : '$r ★',
                        style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _navigateToDetail(UserModel u) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CraftsmanDetailScreen(
          craftsmanId: u.uid,
          name: u.fullName ?? 'حرفي',
          specialty: _specialtyName(u),
          wilaya: u.wilaya ?? '',
          rating: u.rating,
          ratingCount: u.ratingCount,
          bio: u.bio,
          priceNote: u.priceNote,
          phone: u.phone,
          photoUrl: u.photoUrl,
          experienceYears: u.yearsOfExperience,
          workPhotos: u.workPhotos,
        ),
      ),
    );
  }
}
