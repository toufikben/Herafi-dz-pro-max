import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/data/algeria_locations.dart';
import '../../../../core/widgets/craftsman_card.dart';
import '../../../../models/user_model.dart';
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text(
          'البحث عن حرفي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filters Area
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _performSearch(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو التخصص...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Location Filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterButton(
                        icon: Icons.location_on_rounded,
                        label: _selectedWilaya ?? 'الولاية',
                        onTap: _showWilayaPicker,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFilterButton(
                        icon: Icons.star_rounded,
                        label: _minRating == 0 ? 'التقييم' : '+$_minRating',
                        onTap: _showRatingPicker,
                      ),
                    ),
                  ],
                ),
                if (_selectedWilaya != null) ...[
                  const SizedBox(height: 10),
                  _buildFilterButton(
                    icon: Icons.map_rounded,
                    label: _selectedCommune ?? 'جميع البلديات',
                    onTap: () {
                      final w = kAlgeriaWilayas.firstWhere((w) => w.nameAr == _selectedWilaya);
                      _showCommunePicker(w);
                    },
                  ),
                ],
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
                : _results.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white38),
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
          Icon(Icons.search_off_rounded, size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 15),
          const Text(
            'لا توجد نتائج تطابق بحثك',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showWilayaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
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
            onTap: () {
              setState(() {
                _selectedWilaya = w.nameAr;
                _selectedCommune = null;
              });
              Navigator.pop(context);
              _performSearch();
              _showCommunePicker(w);
            },
          );
        },
      ),
    );
  }

  void _showCommunePicker(Wilaya wilaya) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
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
            onTap: () {
              setState(() => _selectedCommune = c);
              Navigator.pop(context);
              _performSearch();
            },
          );
        },
      ),
    );
  }

  void _showRatingPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [4, 3, 2, 1, 0].map((r) => ListTile(
          leading: Icon(Icons.star_rounded, color: r > 0 ? Colors.orangeAccent : Colors.white24),
          title: Text(r == 0 ? 'أي تقييم' : '+$r نجوم', style: const TextStyle(color: Colors.white)),
          onTap: () {
            setState(() => _minRating = r.toDouble());
            Navigator.pop(context);
            _performSearch();
          },
        )).toList(),
      ),
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
