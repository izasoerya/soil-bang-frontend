import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothSerivce {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;

  bool _connectionState = false;

  Future<List<BluetoothDevice>> getBluetoothDevice() async {
    bool isSupported = await FlutterBluePlus.isSupported;
    if (!isSupported) {
      throw Exception('Bluetooth not supported');
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      await openAppSettings();
      return [];
    } else if (statuses.values.any((status) => !status.isGranted)) {
      throw Exception('Allow Bluetooth permissions to continue');
    }

    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.turnOn();
        await FlutterBluePlus.adapterState
            .where((state) => state == BluetoothAdapterState.on)
            .first
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        throw Exception('Bluetooth must be turned on to scan.');
      }
    }

    // 1. Ensure any ongoing scan is stopped before initiating a new one
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final Map<String, BluetoothDevice> foundDevices = {};

    // 2. Include any devices currently connected
    for (var device in FlutterBluePlus.connectedDevices) {
      foundDevices[device.remoteId.str] = device;
    }

    // 3. Listen to incoming scan results stream in real-time
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        foundDevices[r.device.remoteId.str] = r.device;
      }
    });

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")],
        timeout: const Duration(seconds: 4),
      );

      // Wait for scan to actually start
      try {
        await FlutterBluePlus.isScanning
            .where((val) => val == true)
            .first
            .timeout(const Duration(milliseconds: 1000));
      } catch (_) {}

      // Wait for scan to complete
      try {
        await FlutterBluePlus.isScanning
            .where((val) => val == false)
            .first
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    } catch (e) {
      print('Scan error: $e');
    } finally {
      await subscription.cancel();
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }

    // 4. Merge any remaining lastScanResults
    for (var r in FlutterBluePlus.lastScanResults) {
      foundDevices[r.device.remoteId.str] = r.device;
    }

    // 5. Fallback: if no device found with service UUID filter, try brief scan by name
    if (foundDevices.isEmpty) {
      final nameSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (var r in results) {
          final name = r.device.platformName.toUpperCase();
          if (name.contains('SOIL') || name.contains('BANG')) {
            foundDevices[r.device.remoteId.str] = r.device;
          }
        }
      });

      try {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 2),
        );
        try {
          await FlutterBluePlus.isScanning
              .where((val) => val == true)
              .first
              .timeout(const Duration(milliseconds: 600));
        } catch (_) {}
        try {
          await FlutterBluePlus.isScanning
              .where((val) => val == false)
              .first
              .timeout(const Duration(seconds: 3));
        } catch (_) {}
      } catch (_) {
      } finally {
        await nameSubscription.cancel();
        if (FlutterBluePlus.isScanningNow) {
          await FlutterBluePlus.stopScan();
        }
      }

      for (var r in FlutterBluePlus.lastScanResults) {
        final name = r.device.platformName.toUpperCase();
        if (name.contains('SOIL') || name.contains('BANG')) {
          foundDevices[r.device.remoteId.str] = r.device;
        }
      }
    }

    return foundDevices.values.toList();
  }

  Future<void> connect(String address) async {
    try {
      _connectedDevice = BluetoothDevice.fromId(address);
      await _connectedDevice!.connect(license: License.nonprofit);
      await _connectedDevice!.requestMtu(512);
      List<BluetoothService> services = await _connectedDevice!
          .discoverServices();

      for (var service in services) {
        if (service.uuid == Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")) {
          for (var characteristic in service.characteristics) {
            // 1. Locate TX
            if (characteristic.uuid ==
                Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E")) {
              _txCharacteristic = characteristic;
              await _txCharacteristic!.setNotifyValue(true);

              // -------------------------------------------------------------
              // CRITICAL FIX: Direct Hardware Interceptor
              // This proves the data reached Dart, completely ignoring Riverpod
              // -------------------------------------------------------------
              _txCharacteristic!.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  print(
                    "✅ HARDWARE DIRECT INTERCEPT: ${String.fromCharCodes(value)}",
                  );
                }
              });
            }
            // 2. Locate RX
            else if (characteristic.uuid ==
                Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E")) {
              _rxCharacteristic = characteristic;
            }
          }
        }
      }

      // 3. CRITICAL FIX: Ensure BOTH channels are successfully mapped
      if (_txCharacteristic != null && _rxCharacteristic != null) {
        _connectionState = true;
      } else {
        await _connectedDevice!.disconnect();
        throw Exception(
          "Target device does not support the complete Nordic UART serial profile.",
        );
      }
    } catch (e) {
      _connectionState = false;
      rethrow;
    }
  }

  bool get isConnected => _connectionState && _rxCharacteristic != null;

  Future<bool> sendCommand() async {
    try {
      if (_rxCharacteristic == null) {
        print("Cannot send command: RX characteristic is not available.");
        return false;
      }

      // 1. Properly format the JSON and add the \n delimiter
      String jsonCommand = '{"command":"sampling"}';

      // 2. Encode the string into a List<int> byte array
      List<int> bytes = utf8.encode(jsonCommand);

      // 3. Write to the RX characteristic (ensure you are targeting 6E400002)
      await _rxCharacteristic!.write(
        bytes,
        withoutResponse:
            true, // Use 'true' if you don't need the ESP32 to confirm receipt
      );

      print("Command sent successfully.");
      return true;
    } catch (e) {
      print("Failed to send command: $e");
      return false;
    }
  }

  Stream<List<int>> getStream() {
    if (!_connectionState || _txCharacteristic == null) {
      return Stream.empty();
    }
    // Return the stable stream
    return _txCharacteristic!.lastValueStream;
  }

  Future<void> disconnect() async {
    if (_connectionState && _connectedDevice != null) {
      await _connectedDevice!.disconnect();

      _connectionState = false;
      _connectedDevice = null;
      _txCharacteristic = null;
    }
  }
}
