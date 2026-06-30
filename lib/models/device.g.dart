// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: (json['id'] as num).toInt(),
  hostName: json['hostName'] as String,
  battery: (json['battery'] as num).toDouble(),
  freeHeap: (json['freeHeap'] as num).toInt(),
  minFreeHeap: (json['minFreeHeap'] as num).toInt(),
  largestBlock: (json['largestBlock'] as num).toInt(),
  lastResetReason: json['lastResetReason'] as String,
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'hostName': instance.hostName,
  'battery': instance.battery,
  'freeHeap': instance.freeHeap,
  'minFreeHeap': instance.minFreeHeap,
  'largestBlock': instance.largestBlock,
  'lastResetReason': instance.lastResetReason,
};
