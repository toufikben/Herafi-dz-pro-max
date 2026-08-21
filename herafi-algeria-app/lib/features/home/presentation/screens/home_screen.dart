import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/widgets/craftsman_card.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../craftsman/presentation/screens/craftsman_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(userServiceProvider).getFeaturedCraftsmen(limit: 15);
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
        _error = AppLocalizations.of(context)?.loadCraftsmenFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Search
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkSurface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.darkSurface,
                          AppColors.darkBackground,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'دليل العمال والحرفيين في جميع ولايات الجزائر',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            title: Text(l10n.appTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search Bar Overlay
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, -30, 16, 20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Text(
                        'ابحث عن اسم، بناء، صباغ، ...',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Categories Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'التخصصات',
                style: TextStyle(
                  color: AppColors.secondary.withOpacity(0.8),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Categories Grid (Circular)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Icon(
                              cat.icon,
                              color: AppColors.secondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.nameAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Featured Craftsmen Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'حرفيون مميزون',
                    style: TextStyle(
                      color: AppColors.secondary.withOpacity(0.8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: const Text('عرض الكل', style: TextStyle(color: AppColors.secondary)),
                  ),
                ],
              ),
            ),
          ),

          // Featured Craftsmen List
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
            )
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('تعذر تحميل الحرفيين', style: TextStyle(color: Colors.white60)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          else if (_featured.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('لا يوجد حرفيون حالياً', style: TextStyle(color: Colors.white60))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
