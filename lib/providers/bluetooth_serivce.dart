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
            .first;
      } catch (e) {
        throw Exception('Bluetooth must be turned on to scan.');
      }
    }

    await FlutterBluePlus.startScan(
      withServices: [Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")],
      timeout: const Duration(seconds: 5),
    );
    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    List<ScanResult> results = FlutterBluePlus.lastScanResults;
    return results.map((r) => r.device).toList();
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

  Future<void> sendCommand() async {
    try {
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
    } catch (e) {
      print("Failed to send command: $e");
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
