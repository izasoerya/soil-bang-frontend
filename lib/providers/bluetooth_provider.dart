import 'dart:convert';

import 'package:bang_soil/models/device.dart';
import 'package:bang_soil/models/sensor.dart';
import 'package:bang_soil/providers/bluetooth_serivce.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetoothServiceProvider = Provider<BluetoothSerivce>((ref) {
  final service = BluetoothSerivce();
  ref.onDispose(() => service.disconnect());

  return service;
});

final rawBluetoothStreamProvider = Provider<Stream<List<int>>>((ref) {
  final bleService = ref.watch(bluetoothServiceProvider);

  return bleService.getStream();
});

final deviceScanProvider = FutureProvider.autoDispose<List<BluetoothDevice>>((
  ref,
) async {
  final service = ref.watch(bluetoothServiceProvider);
  return await service.getBluetoothDevice();
});

final sensorServiceProvider = StreamProvider<Sensor>((ref) async* {
  final bleService = ref.watch(bluetoothServiceProvider);
  final stream = bleService.getStream();

  await for (final List<int> bytes in stream) {
    if (bytes.isEmpty) continue;

    try {
      final String jsonStr = String.fromCharCodes(bytes).trim();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);

      if (jsonMap["type"] == "sensor") {
        yield Sensor.fromJson(jsonMap);
      }
    } catch (e) {
      print('Parser Error: $e');
    }
  }
});

final deviceServiceProvider = StreamProvider<Device>((ref) async* {
  final stream = ref.watch(rawBluetoothStreamProvider);
  final Stream<String> jsonStream = stream
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  await for (final String json in jsonStream) {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(json);
      if (jsonMap["type"] != "device") continue;
      yield Device.fromJson(jsonMap);
    } on FormatException catch (e) {
      print('Bad Packet: $e');
    } catch (e) {
      print('Unexpected parser error: $e');
    }
  }
});
