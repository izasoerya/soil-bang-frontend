import 'package:bang_soil/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SensorHeaderSection extends StatelessWidget {
  const SensorHeaderSection({
    super.key,
    required this.battery,
    required this.createdAt,
    this.sampleId,
    this.lastFetchTime,
  });

  final double battery;
  final DateTime createdAt;
  final int? sampleId;
  final DateTime? lastFetchTime;

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  IconData _batteryIcon() {
    if (battery >= 90) return Icons.battery_full_rounded;
    if (battery >= 70) return Icons.battery_5_bar_rounded;
    if (battery >= 50) return Icons.battery_4_bar_rounded;
    if (battery >= 30) return Icons.battery_3_bar_rounded;
    if (battery >= 15) return Icons.battery_2_bar_rounded;
    if (battery >= 5)  return Icons.battery_1_bar_rounded;
    return Icons.battery_0_bar_rounded;
  }

  Color _batteryColor() {
    if (battery >= 50) return AppColors.green;
    if (battery >= 20) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTime = lastFetchTime ?? createdAt;
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
                    sampleId != null ? 'Sample #$sampleId' : 'Sample #-',
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

            // Last Fetch Time (Beside ID)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatTime(effectiveTime),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Divider
            Container(width: 1, height: 16, color: AppColors.border),
            const SizedBox(width: 10),

            // Battery Indicator
            Icon(_batteryIcon(), color: _batteryColor(), size: 18),
            const SizedBox(width: 5),
            Text(
              '${battery.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
