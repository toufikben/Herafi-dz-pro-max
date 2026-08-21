import 'package:flutter/material.dart';

class WorkPhotosSection extends StatelessWidget {
  final List<String> currentUrls;
  final Function(List<String>) onChanged;

  const WorkPhotosSection({
    super.key,
    required this.currentUrls,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for now since Storage is disabled
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صور الأعمال (معطلة حالياً)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'رفع الصور يتطلب تفعيل خطة Firebase Blaze. الكود جاهز ولكن الميزة معطلة بطلب من المستخدم.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
