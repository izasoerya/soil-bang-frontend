import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bang_soil/providers/bluetooth_provider.dart';
import 'package:bang_soil/views/widgets/molecules/device_section.dart';
import 'package:bang_soil/views/widgets/molecules/sensor_body_section.dart';
import 'package:bang_soil/views/widgets/molecules/sensor_header_section.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends ConsumerState<DashboardPage> {
  late Map<String, String> _lastListDevice;
  String? _selectedDeviceName;

  @override
  Widget build(BuildContext context) {
    final bluetoothService = ref.watch(bluetoothServiceProvider);
    final scanState = ref.watch(deviceScanProvider);
    final sensorState = ref.watch(sensorServiceProvider);

<<<<<<< Updated upstream
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Color.fromRGBO(15, 21, 26, 1)),
      child: scanState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _errorPage(error.toString()),
        data: (devices) {
          _lastListDevice = {
            for (var device in devices)
              device.platformName.isNotEmpty
                      ? device.platformName
                      : "SOIL-BANG-1":
                  device.remoteId.str,
          };
          if (_lastListDevice.isNotEmpty) {
            _selectedDeviceName = _lastListDevice.entries.first.key;
          } else {
            return const Text('No bluetooth device found');
          }
=======
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
>>>>>>> Stashed changes

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DeviceSection(
                  items: _lastListDevice.keys.toList(),
                  selectedValue: _selectedDeviceName!,
                  onDeviceChanged: (String? deviceString) {
                    setState(() {
                      _selectedDeviceName = deviceString;
                    });
                    print('selected listDevice: $deviceString');
                  },
                  onRefreshClick: () {
                    ref.invalidate(deviceScanProvider);
                    setState(() {
                      _selectedDeviceName = null;
                    });
                    print('Refresh clicked');
                  },
                  onConnectClick: () async {
                    final macAddress = _lastListDevice[_selectedDeviceName];
                    if (macAddress != null) {
                      await bluetoothService.connect(macAddress);
                      ref.invalidate(sensorServiceProvider);
                      ref.invalidate(deviceServiceProvider);
                    }
                  },
                ),
                const SizedBox(height: 10),

                sensorState.when(
                  error: (error, stack) => _errorPage(error.toString()),
                  loading: () => const CircularProgressIndicator(),
                  data: (sensor) {
                    return Column(
                      children: [
                        SensorHeaderSection(
                          battery: 87.1,
                          createdAt: DateTime.now(),
                        ),
<<<<<<< Updated upstream
                        const SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(
=======
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
>>>>>>> Stashed changes
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.graphic_eq, color: Colors.white),
                              const Text(
                                'Spectral Data',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        SensorBodySection(sensor: sensor),
                      ],
                    );
                  },
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await bluetoothService.sendCommand();
                  },
                  child: const Text('Perform Data Sampling'),
                ),
<<<<<<< Updated upstream
              ],
            ),
          );
        },
=======
              ),
              Text(
                'Spectral Sensor Dashboard',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
>>>>>>> Stashed changes
      ),
    );
  }

  Widget _errorPage(String errorMsg) {
    return Center(
      child: Text(
        'Fetching bluetooth device error: $errorMsg',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
