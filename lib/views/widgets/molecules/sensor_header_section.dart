import 'package:flutter/material.dart';

class SensorHeaderSection extends StatelessWidget {
  const SensorHeaderSection({
    super.key,
    required this.battery,
    required this.createdAt,
  });

  final double battery;
  final DateTime createdAt;

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
