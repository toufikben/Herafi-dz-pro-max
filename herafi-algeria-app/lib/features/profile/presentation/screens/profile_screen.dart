import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/categories.dart';
import '../../../../models/user_model.dart';
import '../../../../services/current_user_provider.dart';
import '../../../auth/presentation/screens/complete_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(currentUserProvider);

    return asyncUser.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('خطأ: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('يرجى تسجيل الدخول')),
          );
        }
        return _ProfileBody(user: user);
      },
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserModel user;
  const _ProfileBody({required this.user});

  String get _roleLabel {
    switch (user.role) {
      case UserRole.customer:
        return 'زبون';
      case UserRole.craftsman:
        return 'حرفي';
      case UserRole.company:
        return 'مؤسسة';
      case UserRole.group:
        return 'مجموعة حرفيين';
      case UserRole.admin:
        return 'إدارة';
    }
  }

  String get _specialties {
    if (user.specialties.isEmpty) return '—';
    return user.specialties.map((id) {
      final m = kCraftCategories.where((c) => c.id == id);
      return m.isNotEmpty ? m.first.nameAr : id;
    }).join(' • ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person_rounded,
                                size: 44, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.fullName ?? 'بدون اسم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StatCard(
                        label: user.isCraftsman ? 'التقييم' : 'النوع',
                        value: user.isCraftsman
                            ? user.rating.toStringAsFixed(1)
                            : _roleLabel,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: user.isCraftsman ? 'التقييمات' : 'الحساب',
                        value: user.isCraftsman
                            ? '${user.ratingCount}'
                            : (user.isVerified ? 'موثّق' : '—'),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'الولاية',
                        value: user.wilaya ?? '—',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'نوع الحساب',
                          value: _roleLabel,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'الموقع',
                          value:
                              '${user.wilaya ?? '—'} • ${user.commune ?? '—'}',
                        ),
                        if (user.isCraftsman) ...[
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.handyman_outlined,
                            label: 'التخصصات',
                            value: _specialties,
                          ),
                          if (user.yearsOfExperience != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.work_history_outlined,
                              label: 'سنوات الخبرة',
                              value: '${user.yearsOfExperience}',
                            ),
                          ],
                          if (user.bio != null && user.bio!.isNotEmpty) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.info_outline,
                              label: 'نبذة',
                              value: user.bio!,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CompleteProfileScreen(
                              role: user.role,
                              craftsmanType: user.craftsmanType,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('تعديل الملف'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
