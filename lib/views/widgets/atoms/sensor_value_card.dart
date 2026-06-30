import 'package:flutter/material.dart';

class SensorValueCard extends StatelessWidget {
  const SensorValueCard({super.key, required this.entry});

  final MapEntry<String, double> entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(20, 26, 33, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.key,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            entry.value.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
