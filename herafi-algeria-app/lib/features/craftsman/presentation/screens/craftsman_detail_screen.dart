import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../orders/presentation/screens/create_order_screen.dart';

class CraftsmanDetailScreen extends ConsumerWidget {
  final String craftsmanId;
  final String name;
  final String specialty;
  final String wilaya;
  final double rating;
  final int ratingCount;
  final String? bio;
  final String? priceNote;
  final String phone;
  final String? photoUrl;
  final int? experienceYears;
  final List<String> workPhotos;

  const CraftsmanDetailScreen({
    super.key,
    required this.craftsmanId,
    required this.name,
    required this.specialty,
    required this.wilaya,
    required this.rating,
    required this.ratingCount,
    this.bio,
    this.priceNote,
    required this.phone,
    this.photoUrl,
    this.experienceYears,
    this.workPhotos = const [],
  });

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                            ? NetworkImage(photoUrl!)
                            : null,
                        child: photoUrl == null || photoUrl!.isEmpty
                            ? const Icon(Icons.person_rounded,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating + Verified
                  Row(
                    children: [
                      RatingDisplay(rating: rating, count: ratingCount, size: 18),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 16, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'موثّق',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _InfoTile(
                    icon: Icons.location_on_rounded,
                    title: 'الموقع',
                    value: wilaya,
                  ),
                  if (priceNote != null && priceNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.price_change_rounded,
                      title: 'ملاحظة الأسعار',
                      value: priceNote!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.work_history_rounded,
                    title: 'سنوات الخبرة',
                    value: experienceYears != null 
                        ? '$experienceYears سنوات'
                        : 'خبرة مهنية',
                  ),

                  // Bio
                  if (bio != null && bio!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'نبذة',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                  ],

                  // Work photos
                  const SizedBox(height: 24),
                  Text(
                    'أعمال سابقة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (workPhotos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.image_not_supported_rounded, 
                            color: AppColors.textTertiary, size: 32),
                          SizedBox(height: 8),
                          Text('لا توجد صور أعمال حالياً', 
                            style: TextStyle(color: AppColors.textTertiary)),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: workPhotos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, index) {
                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(workPhotos[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Contact buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'اتصال',
                          icon: Icons.phone_rounded,
                          type: AppButtonType.outline,
                          onPressed: _callPhone,
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'واتساب',
                          icon: Icons.chat_rounded,
                          type: AppButtonType.secondary,
                          onPressed: _openWhatsApp,
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'طلب خدمة',
                    icon: Icons.send_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateOrderScreen(
                            craftsmanId: craftsmanId,
                            craftsmanName: name,
                            specialty: specialty,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
