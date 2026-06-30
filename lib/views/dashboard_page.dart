import 'package:bang_soil/providers/bluetooth_provider.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:bang_soil/views/widgets/molecules/app_header.dart';
import 'package:bang_soil/views/widgets/molecules/device_section.dart';
import 'package:bang_soil/views/widgets/molecules/sensor_body_section.dart';
import 'package:bang_soil/views/widgets/molecules/sensor_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends ConsumerState<DashboardPage> {
  Map<String, String> _listNameAndIdDevice = {};
  String? _selectedDeviceName;

  @override
  Widget build(BuildContext context) {
    final bluetoothService = ref.watch(bluetoothServiceProvider);
    final scanState = ref.watch(deviceScanProvider);
    final sensorState = ref.watch(sensorServiceProvider);

    return SafeArea(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: scanState.when(
                loading: () =>
                    const _LoadingState(message: 'Scanning for devices...'),
                error: (error, stack) => _ErrorState(message: error.toString()),
                data: (devices) {
                  _listNameAndIdDevice = {
                    for (final BluetoothDevice device in devices)
                      (device.platformName.isNotEmpty
                              ? device.platformName
                              : 'Unknown ${device.remoteId.str}'):
                          device.remoteId.str,
                  };

                  if (_listNameAndIdDevice.isEmpty) {
                    return _EmptyState(
                      onRetry: () => ref.invalidate(deviceScanProvider),
                    );
                  } else {
                    _selectedDeviceName =
                        _listNameAndIdDevice.entries.first.key;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        DeviceSection(
                          items: _listNameAndIdDevice.keys.toList(),
                          selectedValue: _selectedDeviceName!,
                          onDeviceChanged: (value) {
                            setState(() => _selectedDeviceName = value);
                          },
                          onRefreshClick: () {
                            ref.invalidate(deviceScanProvider);
                            setState(() => _selectedDeviceName = null);
                          },
                          onConnectClick: () async {
                            final macAddress =
                                _listNameAndIdDevice[_selectedDeviceName];
                            if (macAddress != null) {
                              await bluetoothService.connect(macAddress);
                              ref.invalidate(sensorServiceProvider);
                              ref.invalidate(deviceServiceProvider);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        sensorState.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: _LoadingState(
                              message:
                                  'Perform Data Sampling to Fetch New Data',
                            ),
                          ),
                          error: (error, stack) =>
                              _ErrorState(message: error.toString()),
                          data: (sensor) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SensorHeaderSection(
                                battery: 87.1,
                                createdAt: DateTime.now(),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                  vertical: 4,
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.graphic_eq_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Spectral Data',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              SensorBodySection(sensor: sensor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await bluetoothService.sendCommand();
                              },
                              icon: const Icon(Icons.sensors_rounded, size: 18),
                              label: const Text('Perform Data Sampling'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.do_not_disturb_off_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.red,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.bluetooth_searching_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No device found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure your SOIL-BANG sensor\nis powered on and nearby.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}
