import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/data/algeria_locations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/order_service.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../services/current_user_provider.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  final String craftsmanId;
  final String craftsmanName;
  final String specialty;
  final String? categoryId;

  const CreateOrderScreen({
    super.key,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.specialty,
    this.categoryId,
  });

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedWilaya;
  String? _selectedCommune;
  bool _isImmediate = true;
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  bool _isLoading = false;

  final List<String> _wilayas = getWilayaNames();

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _preferredDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _preferredTime = time);
  }

  Future<void> _submitOrder() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectWilaya)),
      );
      return;
    }
    if (!_isImmediate && (_preferredDate == null || _preferredTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAppointmentFirst)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final customerId = currentUser?.uid ?? authService.currentUid;

    if (customerId == null || customerId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mustLoginFirst),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    DateTime? preferredTime;
    if (!_isImmediate && _preferredDate != null && _preferredTime != null) {
      preferredTime = DateTime(
        _preferredDate!.year,
        _preferredDate!.month,
        _preferredDate!.day,
        _preferredTime!.hour,
        _preferredTime!.minute,
      );
    }

    final orderService = ref.read(orderServiceProvider);

    try {
      await orderService.createOrder(
        customerId: customerId,
        craftsmanId: widget.craftsmanId,
        categoryId: widget.categoryId ?? widget.specialty,
        description: _descriptionController.text.trim(),
        wilaya: _selectedWilaya!,
        commune: _selectedCommune ?? '',
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        preferredTime: preferredTime,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sendOrderFailed(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.orderSentSuccessfully,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.craftsmanWillBeNotified(
                  widget.craftsmanName),
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.ok,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderService)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.craftsmanName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          widget.specialty,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.problemDescription,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.problemDescriptionHint,
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? l10n.descriptionTooShort
                  : null,
            ),
            const SizedBox(height: 20),
            Text(l10n.location,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedWilaya,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city_rounded),
                hintText: l10n.selectWilaya,
              ),
              items: _wilayas
                  .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedWilaya = v;
                _selectedCommune = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCommune,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined),
                hintText: 'البلدية',
              ),
              items: _selectedWilaya != null
                  ? getCommunesForWilaya(_selectedWilaya!)
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList()
                  : [],
              onChanged: (v) => setState(() => _selectedCommune = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: l10n.detailedAddressOptional,
                prefixIcon: const Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.serviceTime,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    label: l10n.immediate,
                    icon: Icons.flash_on_rounded,
                    isSelected: _isImmediate,
                    onTap: () => setState(() => _isImmediate = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeChip(
                    label: l10n.laterAppointment,
                    icon: Icons.calendar_month_rounded,
                    isSelected: !_isImmediate,
                    onTap: () => setState(() => _isImmediate = false),
                  ),
                ),
              ],
            ),
            if (!_isImmediate) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(
                        _preferredDate != null
                            ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                            : l10n.selectDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(
                        _preferredTime != null
                            ? _preferredTime!.format(context)
                            : l10n.selectTime,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: l10n.sendOrder,
              icon: Icons.send_rounded,
              onPressed: _submitOrder,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
