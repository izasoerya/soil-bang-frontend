import 'package:bang_soil/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SensorHeaderSection extends StatelessWidget {
  const SensorHeaderSection({
    super.key,
    required this.battery,
    required this.createdAt,
  });

  final double battery;
  final DateTime createdAt;

<<<<<<< Updated upstream
=======
  IconData _batteryIcon() {
    if (battery >= 90) return Icons.battery_full_rounded;
    if (battery >= 70) return Icons.battery_5_bar_rounded;
    if (battery >= 50) return Icons.battery_4_bar_rounded;
    if (battery >= 30) return Icons.battery_3_bar_rounded;
    if (battery >= 15) return Icons.battery_2_bar_rounded;
    if (battery >= 5) return Icons.battery_1_bar_rounded;
    return Icons.battery_0_bar_rounded;
  }

  Color _batteryColor() {
    if (battery >= 50) return AppColors.green;
    if (battery >= 20) return AppColors.amber;
    return AppColors.red;
  }

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width * 0.05;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(_batteryIcon(), color: _batteryColor(), size: 20),
            const SizedBox(width: 6),
            Text(
              '${battery.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(width: 1, height: 16, color: AppColors.border),
            const Spacer(),
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              createdAt.toString().substring(11, 16),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
