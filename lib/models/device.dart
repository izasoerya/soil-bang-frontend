import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  final int id;
  final String hostName;
  final double battery;
  final int freeHeap;
  final int minFreeHeap;
  final int largestBlock;
  final String lastResetReason;

  Device({
    required this.id,
    required this.hostName,
    required this.battery,
    required this.freeHeap,
    required this.minFreeHeap,
    required this.largestBlock,
    required this.lastResetReason,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
