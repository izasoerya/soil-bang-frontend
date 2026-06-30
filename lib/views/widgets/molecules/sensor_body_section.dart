import 'package:bang_soil/models/sensor.dart';
import 'package:bang_soil/views/widgets/atoms/sensor_value_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorBodySection extends StatelessWidget {
  const SensorBodySection({super.key, required this.sensor});

  final Sensor sensor;

  @override
  Widget build(BuildContext context) {
    // 1. Process and sort all 18 channel data spots
    final allSpots = sensor.spectralChannels.entries.map((entry) {
      final wavelength = double.parse(entry.key.replaceAll(' nm', ''));
      return FlSpot(wavelength, entry.value);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

    // 2. Split spots based on spectrum wavelength domain cutoffs
    final visibleSpots = allSpots.where((spot) => spot.x <= 705).toList();
    final irSpots = allSpots.where((spot) => spot.x >= 730).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // CHART 1: VISIBLE LIGHT SPECTRUM (UV-VIS)
        // ==========================================
        _buildSectionHeader(
          'Visible Spectrum (410nm - 705nm)',
          Colors.cyanAccent,
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.2,
          padding: const EdgeInsets.only(right: 24, left: 8, top: 8),
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: LineChart(
            _buildChartData(
              spots: visibleSpots,
              minX: 400,
              maxX: 710,
              lineColor: Colors.cyanAccent,
              intervalX: 50,
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildSectionHeader(
          'Near-Infrared Spectrum (730nm - 940nm)',
          Colors.redAccent,
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.2,
          padding: const EdgeInsets.only(right: 24, left: 8, top: 8),
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: LineChart(
            _buildChartData(
              spots: irSpots,
              minX: 720,
              maxX: 950,
              lineColor: Colors.redAccent,
              intervalX: 50,
            ),
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('Raw Channel Matrix (μW/cm²)', Colors.white),

        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: sensor.spectralChannels.length,
            itemBuilder: (context, index) {
              final entry = sensor.spectralChannels.entries.elementAt(index);
              return SensorValueCard(entry: entry);
            },
          ),
        ),
      ],
    );
  }

  /// Helper configuration template to share chart setups
  LineChartData _buildChartData({
    required List<FlSpot> spots,
    required double minX,
    required double maxX,
    required Color lineColor,
    required double intervalX,
  }) {
    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // Y-Axis Labels configuration
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white60, fontSize: 9),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
        // X-Axis Labels configuration
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: intervalX,
            getTitlesWidget: (value, meta) {
              if (value == minX || value == maxX)
                return const SizedBox.shrink();
              return Text(
                '${value.toInt()}',
                style: const TextStyle(color: Colors.white60, fontSize: 9),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
          left: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      minX: minX,
      maxX: maxX,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: lineColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [lineColor.withOpacity(0.15), lineColor.withOpacity(0.0)],
            ),
          ),
        ),
      ],
    );
  }

  /// Clean section label renderer helper
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 4.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
