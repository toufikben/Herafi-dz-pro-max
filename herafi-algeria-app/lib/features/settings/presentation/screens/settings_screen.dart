import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/locale_provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/current_user_provider.dart';
import '../../../auth/presentation/screens/phone_auth_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance Section
          _SectionHeader(title: 'المظهر'),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'الوضع الليلي',
            trailing: Switch.adaptive(
              value: themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark),
              activeTrackColor: AppColors.primary,
              onChanged: (v) {
                ref.read(themeModeProvider.notifier).setThemeMode(
                      v ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'اللغة',
            subtitle: _localeName(locale.languageCode),
            onTap: () => _showLanguageSheet(context, ref),
          ),

          const Divider(height: 32),

          // Account Section
          _SectionHeader(title: 'الحساب'),
          _SettingsTile(
            icon: Icons.edit_rounded,
            title: 'تعديل الملف الشخصي',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.phone_rounded,
            title: 'تغيير رقم الهاتف',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            title: 'الإشعارات',
            trailing: Switch.adaptive(
              value: true,
              activeTrackColor: AppColors.primary,
              onChanged: (v) {},
            ),
          ),

          const Divider(height: 32),

          // Support
          _SectionHeader(title: 'الدعم'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'مركز المساعدة',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'عن التطبيق',
            subtitle: 'الإصدار 1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'سياسة الخصوصية',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'شروط الاستخدام',
            onTap: () {},
          ),

          const Divider(height: 32),

          // Danger Zone
          _SectionHeader(title: 'منطقة الخطر'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'تسجيل الخروج',
            iconColor: AppColors.warning,
            onTap: () => _signOut(context, ref),
          ),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'حذف الحساب',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _localeName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('اختر اللغة',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _LangOption(
                  label: 'العربية',
                  code: 'ar',
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('ar'));
                    Navigator.pop(ctx);
                  },
                ),
                _LangOption(
                  label: 'Français',
                  code: 'fr',
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('fr'));
                    Navigator.pop(ctx);
                  },
                ),
                _LangOption(
                  label: 'English',
                  code: 'en',
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authServiceProvider).signOut();
    } catch (_) {}
    await ref.read(currentUserProvider.notifier).clear();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
      (route) => false,
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(authServiceProvider).deleteAccount();
              } catch (_) {}
              await ref.read(currentUserProvider.notifier).clear();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 13))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textTertiary)
              : null),
      onTap: onTap,
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String code;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
