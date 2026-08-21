import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/theme/app_colors.dart';

class MultiSelectSpecialties extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String>) onChanged;

  const MultiSelectSpecialties({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<MultiSelectSpecialties> createState() => _MultiSelectSpecialtiesState();
}

class _MultiSelectSpecialtiesState extends State<MultiSelectSpecialties> {
  late Set<String> _selected;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kCraftCategories.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.nameAr.toLowerCase().contains(query) ||
          c.nameFr.toLowerCase().contains(query) ||
          c.nameEn.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن تخصص (مثلاً: سباك، كهربائي...)',
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filtered.map((cat) {
            final isSelected = _selected.contains(cat.id);
            return FilterChip(
              label: Text(cat.nameAr),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selected.add(cat.id);
                  } else {
                    _selected.remove(cat.id);
                  }
                  widget.onChanged(_selected);
                });
              },
              selectedColor: AppColors.primarySurface,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('لا توجد نتائج تطابق بحثك')),
          ),
      ],
    );
  }
}
