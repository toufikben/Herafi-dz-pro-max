import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../../models/user_model.dart';

class CraftsmanCard extends StatelessWidget {
  final UserModel user;
  final String specialty;
  final VoidCallback onTap;

  const CraftsmanCard({
    super.key,
    required this.user,
    required this.specialty,
    required this.onTap,
  });

  Future<void> _makeCall() async {
    if (user.phone == null) return;
    final Uri url = Uri.parse('tel:${user.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp() async {
    if (user.phone == null) return;
    String cleanPhone = user.phone!.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('213')) {
      // Already has country code
    } else if (cleanPhone.startsWith('0')) {
      cleanPhone = '213${cleanPhone.substring(1)}';
    } else {
      cleanPhone = '213$cleanPhone';
    }
    
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Neon gradient accent
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, Colors.transparent],
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with Neon Glow
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.darkBackground,
                            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                            child: user.photoUrl == null
                                ? const Icon(Icons.person_rounded, color: AppColors.secondary, size: 32)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.fullName ?? 'حرفي',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  if (user.isVerified)
                                    const Icon(Icons.verified_rounded, size: 18, color: Colors.blueAccent),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                specialty,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: Colors.white38, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.wilaya ?? ''} - ${user.commune ?? ''}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Rating & Experience Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          _buildStatItem(
                            icon: Icons.star_rounded,
                            value: user.rating.toStringAsFixed(1),
                            label: '${user.ratingCount} تقييم',
                            color: Colors.orangeAccent,
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: Colors.white10,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          _buildStatItem(
                            icon: Icons.work_history_rounded,
                            value: '${user.yearsOfExperience ?? 0}',
                            label: 'سنوات خبرة',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Direct Contact Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactButton(
                            onPressed: _makeCall,
                            icon: Icons.phone_in_talk_rounded,
                            label: 'اتصال',
                            color: const Color(0xFF2962FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactButton(
                            onPressed: _openWhatsApp,
                            icon: Icons.chat_bubble_rounded,
                            label: 'واتساب',
                            color: const Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
