import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../home/presentation/screens/main_shell.dart';
import 'complete_profile_screen.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selectedRole;
  CraftsmanType? _selectedCraftsmanType;

  void _continue() {
    if (_selectedRole == null) return;

    if (_selectedRole == UserRole.customer) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(role: UserRole.customer),
        ),
      );
    } else {
      // حرفي / مؤسسة / مجموعة
      if (_selectedCraftsmanType == null) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(
            role: _selectedRole!,
            craftsmanType: _selectedCraftsmanType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'كيف تريد استخدام التطبيق؟',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'اختر نوع حسابك للمتابعة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Customer Card
              _RoleCard(
                title: 'أنا زبون',
                subtitle: 'أبحث عن حرفي لخدمتي',
                icon: Icons.person_search_rounded,
                isSelected: _selectedRole == UserRole.customer,
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.customer;
                    _selectedCraftsmanType = null;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Craftsman Card
              _RoleCard(
                title: 'أنا حرفي / مؤسسة',
                subtitle: 'أقدم خدماتي للزبائن',
                icon: Icons.handyman_rounded,
                isSelected: _selectedRole == UserRole.craftsman ||
                    _selectedRole == UserRole.company ||
                    _selectedRole == UserRole.group,
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.craftsman;
                  });
                },
              ),

              // Craftsman type options
              if (_selectedRole == UserRole.craftsman ||
                  _selectedRole == UserRole.company ||
                  _selectedRole == UserRole.group) ...[
                const SizedBox(height: 16),
                Text(
                  'نوع الحساب',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'شخصي',
                        isSelected:
                            _selectedCraftsmanType == CraftsmanType.personal,
                        onTap: () => setState(() {
                          _selectedCraftsmanType = CraftsmanType.personal;
                          _selectedRole = UserRole.craftsman;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeChip(
                        label: 'مؤسسة',
                        isSelected:
                            _selectedCraftsmanType == CraftsmanType.company,
                        onTap: () => setState(() {
                          _selectedCraftsmanType = CraftsmanType.company;
                          _selectedRole = UserRole.company;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeChip(
                        label: 'مجموعة',
                        isSelected:
                            _selectedCraftsmanType == CraftsmanType.group,
                        onTap: () => setState(() {
                          _selectedCraftsmanType = CraftsmanType.group;
                          _selectedRole = UserRole.group;
                        }),
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              ElevatedButton(
                onPressed: (_selectedRole == UserRole.customer ||
                        _selectedCraftsmanType != null)
                    ? _continue
                    : null,
                child: const Text('متابعة'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 26),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
