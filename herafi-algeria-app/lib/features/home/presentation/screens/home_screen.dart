import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/widgets/craftsman_card.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../craftsman/presentation/screens/craftsman_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<UserModel> _featured = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(userServiceProvider).getFeaturedCraftsmen(limit: 20);
      if (!mounted) return;
      setState(() {
        _featured = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _featured = [];
        _loading = false;
        _error = "تعذر تحميل البيانات";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: const Text(
                'حرفي الجزائر',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary.withOpacity(0.15),
                      AppColors.darkBackground,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.secondary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'ابحث عن حرفي أو تخصص...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Specialties Horizontal List
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Text(
                    'التخصصات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: kCraftCategories.length,
                    itemBuilder: (context, index) {
                      final cat = kCraftCategories[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(initialCategoryId: cat.id),
                          ),
                        ),
                        child: Container(
                          width: 85,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.secondary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: AppColors.secondary,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.nameAr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Featured Craftsmen
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'حرفيون مميزون',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
            )
          else if (_featured.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'لا يوجد حرفيون حالياً',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final u = _featured[index];
                    return CraftsmanCard(
                      user: u,
                      specialty: _specialtyName(u),
                      onTap: () => _navigateToDetail(context, u),
                    );
                  },
                  childCount: _featured.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _specialtyName(UserModel u) {
    if (u.specialties.isEmpty) return 'حرفة عامة';
    final cat = kCraftCategories.where((c) => c.id == u.specialties.first);
    return cat.isNotEmpty ? cat.first.nameAr : u.specialties.first;
  }

  void _navigateToDetail(BuildContext context, UserModel u) {
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
