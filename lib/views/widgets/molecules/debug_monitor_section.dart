import 'dart:convert';

import 'package:bang_soil/providers/bluetooth_provider.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RawBluetoothDebugDialog extends ConsumerWidget {
  const RawBluetoothDebugDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorState = ref.watch(sensorServiceProvider);
    final deviceState = ref.watch(deviceServiceProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Bluetooth Debug',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 340,
        height: 320,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DebugPayloadCard(
                  title: 'Sensor Provider',
                  payload: sensorState.maybeWhen(
                    data: (sensor) {
                      print('✓ Sensor Data Loaded');
                      return const JsonEncoder.withIndent(
                        '  ',
                      ).convert(sensor.toJson());
                    },
                    loading: () {
                      print('🔄 Sensor Loading');
                      return 'Loading sensor data...';
                    },
                    error: (error, stack) {
                      print('✗ Sensor Error: $error');
                      return 'Sensor error: $error';
                    },
                    orElse: () => 'Unknown state',
                  ),
                ),
                const SizedBox(height: 12),
                _DebugPayloadCard(
                  title: 'Device Provider',
                  payload: deviceState.maybeWhen(
                    data: (device) {
                      print('✓ Device Data Loaded');
                      return const JsonEncoder.withIndent(
                        '  ',
                      ).convert(device.toJson());
                    },
                    loading: () {
                      print('🔄 Device Loading');
                      return 'Loading device data...';
                    },
                    error: (error, stack) {
                      print('✗ Device Error: $error');
                      return 'Device error: $error';
                    },
                    orElse: () => 'Unknown state',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'State: ${sensorState.runtimeType} / ${deviceState.runtimeType}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DebugPayloadCard extends StatelessWidget {
  const _DebugPayloadCard({required this.title, required this.payload});

  final String title;
  final String payload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: SelectableText(
            payload,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.4,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
