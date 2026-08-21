import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../services/current_user_provider.dart';
import 'home_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../orders/presentation/screens/craftsman_orders_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

final mainTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isCraftsman = user?.isCraftsman == true;

    final pages = <Widget>[
      const HomeScreen(),
      isCraftsman ? const CraftsmanOrdersScreen() : const OrdersScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    final labels = isCraftsman
        ? const ['الرئيسية', 'طلبات العمل', 'حسابي', 'الإعدادات']
        : const ['الرئيسية', 'طلباتي', 'حسابي', 'الإعدادات'];

    final icons = isCraftsman
        ? const [
            Icons.home_rounded,
            Icons.work_rounded,
            Icons.person_rounded,
            Icons.settings_rounded,
          ]
        : const [
            Icons.home_rounded,
            Icons.receipt_long_rounded,
            Icons.person_rounded,
            Icons.settings_rounded,
          ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                return _NavItem(
                  icon: icons[i],
                  label: labels[i],
                  isSelected: currentIndex == i,
                  onTap: () =>
                      ref.read(mainTabProvider.notifier).state = i,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 24,
                color:
                    isSelected ? AppColors.primary : AppColors.textTertiary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
