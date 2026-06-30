import 'package:json_annotation/json_annotation.dart';
part 'sensor.g.dart';

@JsonSerializable()
class Sensor {
  final double nm410;
  final double nm435;
  final double nm460;
  final double nm485;
  final double nm510;
  final double nm535;

  // AS72652 (VIS to NIR)
  final double nm560;
  final double nm585;
  final double nm610;
  final double nm645;
  final double nm680;
  final double nm705;

  // AS72651 (NIR)
  final double nm730;
  final double nm760;
  final double nm810;
  final double nm860;
  final double nm900;
  final double nm940;

  // Temperature of the IC
  final double as72651Temp;
  final double as72652Temp;
  final double as72653Temp;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime createdAt;

  Sensor({
    required this.nm410,
    required this.nm435,
    required this.nm460,
    required this.nm485,
    required this.nm510,
    required this.nm535,
    required this.nm560,
    required this.nm585,
    required this.nm610,
    required this.nm645,
    required this.nm680,
    required this.nm705,
    required this.nm730,
    required this.nm760,
    required this.nm810,
    required this.nm860,
    required this.nm900,
    required this.nm940,
    required this.as72651Temp,
    required this.as72652Temp,
    required this.as72653Temp,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);

  Map<String, dynamic> toJson() => _$SensorToJson(this);
}

extension SensorIterationExtension on Sensor {
  /// Automated iterator for all 18 spectral channels
  Map<String, double> get spectralChannels {
    final rawMap =
        toJson(); // Converts model properties using json_serializable [cite: 2691]

    // 1. Filter out metadata keys and keep only the numeric "nmXXX" channels
    final channelEntries = rawMap.entries.where((e) {
      return e.key.startsWith('nm') && e.value is num;
    });

    // 2. Map the keys cleanly to human-readable strings (e.g., "nm410" -> "410 nm")
    return Map.fromEntries(
      channelEntries.map((e) {
        final formattedKey = '${e.key.replaceAll('nm', '')} nm';
        return MapEntry(formattedKey, (e.value as num).toDouble());
      }),
    );
  }

  /// Automated iterator for the 3 IC internal silicon die temperatures [cite: 2257]
  Map<String, double> get chipTemperatures {
    return {
      'Master NIR (AS72651)': as72651Temp,
      'Visible Light (AS72652)': as72652Temp,
      'UV-Visible (AS72653)': as72653Temp,
    };
  }
}
