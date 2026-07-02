import 'dart:convert';

import 'package:bang_soil/models/sensor.dart';
import 'package:bang_soil/providers/bluetooth_provider.dart';
import 'package:bang_soil/services/csv_export_service.dart';
import 'package:bang_soil/services/database_service.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:bang_soil/views/widgets/molecules/device_section.dart';
import 'package:bang_soil/views/widgets/molecules/sensor_body_section.dart';
import 'package:bang_soil/views/widgets/molecules/sensor_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends ConsumerState<DashboardPage> {
  Map<String, String> _lastListDevice = {};
  String? _selectedDeviceName;

  final _csvExportService = CsvExportService();

  Future<void> _handleExportCSV() async {
    try {
      await _csvExportService.exportToCSV();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleResetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Reset Data',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Semua data sensor yang tersimpan akan dihapus permanen. Yakin ingin melanjutkan?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteAllReadings();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil direset')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = ref.watch(bluetoothServiceProvider);
    final scanState = ref.watch(deviceScanProvider);
    final sensorState = ref.watch(sensorServiceProvider);
    final deviceState = ref.watch(deviceServiceProvider);
    final deviceBattery = deviceState.value?.battery ?? 0.0;

    ref.listen<AsyncValue<Sensor>>(sensorServiceProvider, (_, next) {
      next.whenData((sensor) => DatabaseService.instance.insertSensor(sensor));
    });

    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: scanState.when(
                loading: () =>
                    const _LoadingState(message: 'Scanning for devices...'),
                error: (error, stack) => _ErrorState(message: error.toString()),
                data: (devices) {
                  _lastListDevice = {
                    for (var device in devices)
                      (device.platformName.isNotEmpty
                              ? device.platformName
                              : 'SOIL-BANG-1'):
                          device.remoteId.str,
                  };

                  if (_lastListDevice.isEmpty) {
                    return _EmptyState(
                      onRetry: () => ref.invalidate(deviceScanProvider),
                    );
                  }

                  if (_selectedDeviceName == null ||
                      !_lastListDevice.containsKey(_selectedDeviceName)) {
                    _selectedDeviceName = _lastListDevice.entries.first.key;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        DeviceSection(
                          items: _lastListDevice.keys.toList(),
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
                                _lastListDevice[_selectedDeviceName];
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
                              message: 'Reading sensor data...',
                            ),
                          ),
                          error: (error, stack) =>
                              _ErrorState(message: error.toString()),
                          data: (sensor) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SensorHeaderSection(
                                battery: deviceBattery,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOIL-BANG',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Spectral Sensor Dashboard',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          PopupMenuButton<_HeaderAction>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
            ),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            onSelected: (action) {
              if (action == _HeaderAction.exportCSV) {
                _handleExportCSV();
              } else if (action == _HeaderAction.debugRawBluetooth) {
                _showRawBluetoothDebugDialog();
              } else if (action == _HeaderAction.resetData) {
                _handleResetData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _HeaderAction.exportCSV,
                child: Row(
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Export CSV',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _HeaderAction.debugRawBluetooth,
                child: Row(
                  children: [
                    Icon(
                      Icons.bug_report_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Debug Raw Bluetooth',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _HeaderAction.resetData,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.red,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Reset Data',
                      style: TextStyle(color: AppColors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRawBluetoothDebugDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const _RawBluetoothDebugDialog(),
    );
  }
}

enum _HeaderAction { exportCSV, debugRawBluetooth, resetData }

class _RawBluetoothDebugDialog extends ConsumerWidget {
  const _RawBluetoothDebugDialog();

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

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    print('loading');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
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
