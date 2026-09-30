import 'package:bang_soil/models/sensor.dart';
import 'package:bang_soil/providers/bluetooth_provider.dart';
import 'package:bang_soil/services/database_service.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:bang_soil/views/widgets/atoms/modal.dart';
import 'package:bang_soil/views/widgets/molecules/app_header_section.dart';
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
  bool _isSampling = false;
  int? _lastSamplingId;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    _loadLastSamplingInfo();
  }

  Future<void> _loadLastSamplingInfo() async {
    final lastReading = await DatabaseService.instance.getLastReading();
    if (lastReading != null && mounted) {
      setState(() {
        _lastSamplingId = lastReading['id'] as int?;
        if (lastReading['created_at'] != null) {
          _lastFetchTime =
              DateTime.tryParse(lastReading['created_at'].toString());
        }
      });
    }
  }

  void _handleDataReset() {
    setState(() {
      _lastSamplingId = null;
      _lastFetchTime = null;
    });
  }

  Future<void> _handleSampling(dynamic bluetoothService) async {
    final confirmed = await AppModal.showConfirmation(
      context: context,
      title: 'Sampling Confirmation',
      message: 'Are you sure you want to perform data sampling?',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
      icon: Icons.sensors_rounded,
    );

    if (confirmed != true || !mounted) return;

    if (!bluetoothService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device not connected. Please connect first.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isSampling = true);

    final success = await bluetoothService.sendCommand();
    if (!mounted) return;

    if (!success) {
      setState(() => _isSampling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send sampling command.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    // Safety timeout in case the device does not respond within 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (_isSampling && mounted) {
        setState(() => _isSampling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Sampling timed out. No response received from device.'),
            backgroundColor: AppColors.amber,
          ),
        );
      }
    });
  }

  bool _isManualScanning = false;

  Future<void> _handleScanDevices() async {
    if (_isManualScanning) return;
    setState(() {
      _isManualScanning = true;
      _selectedDeviceName = null;
    });
    try {
      ref.invalidate(deviceScanProvider);
      await ref.read(deviceScanProvider.future);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isManualScanning = false);
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
      next.whenData((sensor) async {
        final id = await DatabaseService.instance.insertSensor(sensor);
        if (!mounted) return;

        setState(() {
          _lastSamplingId = id;
          _lastFetchTime = sensor.createdAt;
        });

        if (_isSampling) {
          setState(() => _isSampling = false);
          AppModal.showSuccess(
            context: context,
            title: 'Sampling Successful',
            message: 'Success taking data (Sample #$id)',
            closeText: 'Close',
          );
        }
      });
    });

    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Column(
          children: [
            AppHeaderSection(onDataReset: _handleDataReset),
            Expanded(
              child: Builder(
                builder: (context) {
                  final isScanning = _isManualScanning ||
                      scanState.isLoading ||
                      scanState.isRefreshing;

                  // 1. Error state when no data exists
                  if (scanState.hasError &&
                      !isScanning &&
                      !scanState.hasValue) {
                    return _ErrorState(
                      message: scanState.error.toString(),
                      onRetry: _handleScanDevices,
                    );
                  }

                  // 2. Initial loading state (no data yet)
                  if (scanState.isLoading && !scanState.hasValue) {
                    return _EmptyState(
                      isScanning: true,
                      onRetry: _handleScanDevices,
                    );
                  }

                  // 3. Process devices
                  final devices = scanState.value ?? [];
                  _lastListDevice = {
                    for (var device in devices)
                      (device.platformName.isNotEmpty
                              ? device.platformName
                              : 'SOIL-BANG-1'):
                          device.remoteId.str,
                  };

                  // 4. Empty state or active rescan
                  if (_lastListDevice.isEmpty) {
                    return _EmptyState(
                      isScanning: isScanning,
                      onRetry: _handleScanDevices,
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
                          onRefreshClick: _handleScanDevices,
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
                                createdAt: _lastFetchTime ?? sensor.createdAt,
                                sampleId: _lastSamplingId,
                                lastFetchTime:
                                    _lastFetchTime ?? sensor.createdAt,
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
                              onPressed: _isSampling
                                  ? null
                                  : () => _handleSampling(bluetoothService),
                              icon: _isSampling
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.sensors_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                _isSampling
                                    ? 'Sampling in progress...'
                                    : 'Perform Data Sampling',
                              ),
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
  const _ErrorState({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

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
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  const _EmptyState({
    required this.isScanning,
    required this.onRetry,
  });

  final bool isScanning;
  final VoidCallback onRetry;

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _EmptyState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RadarPulseIcon(
              animation: _controller,
              isScanning: widget.isScanning,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isScanning ? 'Scanning for devices...' : 'No device found',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isScanning
                  ? 'Searching for nearby SOIL-BANG sensors...'
                  : 'Make sure your SOIL-BANG sensor\nis powered on and nearby.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: widget.isScanning ? null : widget.onRetry,
              icon: widget.isScanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: Text(widget.isScanning ? 'Scanning...' : 'Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarPulseIcon extends StatelessWidget {
  const _RadarPulseIcon({
    required this.animation,
    required this.isScanning,
  });

  final Animation<double> animation;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    if (!isScanning) {
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.bluetooth_searching_rounded,
          color: AppColors.primary,
          size: 36,
        ),
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final wave1 = progress;
        final wave2 = (progress + 0.5) % 1.0;

        return SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildWaveRing(wave1),
              _buildWaveRing(wave2),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: 0.3 * (1.0 - (progress - 0.5).abs()),
                      ),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaveRing(double waveProgress) {
    final size = 76.0 + (waveProgress * 54.0);
    final opacity = (1.0 - waveProgress).clamp(0.0, 1.0) * 0.45;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: opacity),
          width: 2.0,
        ),
      ),
    );
  }
}
