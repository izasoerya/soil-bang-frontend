import 'package:bang_soil/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DropdownDevice extends StatelessWidget {
  const DropdownDevice({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<String> items;
  final String selectedValue;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: AppColors.surfaceInput,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}
