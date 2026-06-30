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
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(26, 34, 41, 1),
        border: Border.all(color: Colors.grey.shade600, width: 0.25),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      padding: EdgeInsetsGeometry.symmetric(vertical: 12.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.battery_0_bar, color: Colors.green),
              Text('Battery: $battery%', style: TextStyle(color: Colors.white)),
            ],
          ),
          Divider(color: Colors.white, height: 2, thickness: 2),
          Text(
            'Last Update: ${createdAt.toString().substring(11, 16)}',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
