import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/star_rating.dart';

class RatingDialog extends StatefulWidget {
  final String craftsmanName;
  final Function(int rating) onSubmit;

  const RatingDialog({
    super.key,
    required this.craftsmanName,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onSubmit(_rating);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              size: 48,
              color: AppColors.star,
            ),
            const SizedBox(height: 16),
            Text(
              'قيم الحرفي',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              widget.craftsmanName,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            StarRating(
              rating: _rating.toDouble(),
              size: 40,
              interactive: true,
              onRatingChanged: (value) {
                setState(() => _rating = value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _rating == 0
                  ? 'اختر عدد النجوم'
                  : _ratingLabel(_rating),
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'إرسال التقييم',
              onPressed: _rating > 0 ? _submit : null,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لاحقاً'),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'متوسط';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }
}
