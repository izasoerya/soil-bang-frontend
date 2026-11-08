import 'package:bang_soil/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SensorHeaderSection extends StatelessWidget {
  const SensorHeaderSection({
    super.key,
    required this.createdAt,
    this.battery,
    this.sampleId,
    this.lastFetchTime,
    this.ledLabel = 'Unknown LED',
    this.sampleIndex = 1,
    this.sampleCount = 3,
  });

  final double? battery;
  final DateTime createdAt;
  final int? sampleId;
  final DateTime? lastFetchTime;
  final String ledLabel;
  final int sampleIndex;
  final int sampleCount;

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width * 0.05;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Sample ID Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tag_rounded,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sample #$sampleIndex',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            const Spacer(),
            Text(
              ledLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 16, color: AppColors.border),
            const SizedBox(width: 12),
            Text(
              (lastFetchTime ?? createdAt).toIso8601String().substring(11, 19),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
