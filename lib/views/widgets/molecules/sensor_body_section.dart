import 'package:bang_soil/models/sensor.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:bang_soil/views/widgets/atoms/sensor_value_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorBodySection extends StatelessWidget {
  const SensorBodySection({super.key, required this.sensor});

  final Sensor sensor;

  @override
  Widget build(BuildContext context) {
    final allSpots = sensor.spectralChannels.entries.map((entry) {
      final wavelength = double.parse(entry.key.replaceAll(' nm', ''));
      return FlSpot(wavelength, entry.value);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

<<<<<<< Updated upstream
    // 2. Split spots based on spectrum wavelength domain cutoffs
    final visibleSpots = allSpots.where((spot) => spot.x <= 705).toList();
    final irSpots = allSpots.where((spot) => spot.x >= 730).toList();
=======
    final visibleSpots = allSpots.where((s) => s.x <= 705).toList();
    final irSpots = allSpots.where((s) => s.x >= 730).toList();
    final hPad = MediaQuery.of(context).size.width * 0.05;
>>>>>>> Stashed changes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< Updated upstream
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
=======
        _buildSectionHeader(
          'Visible Spectrum',
          '410nm – 705nm',
          AppColors.cyanLine,
        ),
        _buildChart(
          context,
          visibleSpots,
          minX: 400,
          maxX: 710,
          lineColor: AppColors.cyanLine,
          intervalX: 50,
>>>>>>> Stashed changes
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('Raw Channel Matrix (μW/cm²)', Colors.white),

<<<<<<< Updated upstream
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
=======
        _buildSectionHeader(
          'Near-Infrared',
          '730nm – 940nm',
          AppColors.redLine,
        ),
        _buildChart(
          context,
          irSpots,
          minX: 720,
          maxX: 950,
          lineColor: AppColors.redLine,
          intervalX: 50,
        ),

        const SizedBox(height: 24),

        _buildSectionHeader(
          'Raw Channel Matrix',
          'μW/cm²',
          AppColors.textSecondary,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
>>>>>>> Stashed changes
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
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

  Widget _buildChart(
    BuildContext context,
    List<FlSpot> spots, {
    required double minX,
    required double maxX,
    required Color lineColor,
    required double intervalX,
  }) {
    final hPad = MediaQuery.of(context).size.width * 0.05;
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.22,
      padding: const EdgeInsets.only(right: 20, left: 4, top: 8, bottom: 4),
      margin: EdgeInsets.symmetric(horizontal: hPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        _buildChartData(
          spots: spots,
          minX: minX,
          maxX: maxX,
          lineColor: lineColor,
          intervalX: intervalX,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData({
    required List<FlSpot> spots,
    required double minX,
    required double maxX,
    required Color lineColor,
    required double intervalX,
  }) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppColors.border, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
<<<<<<< Updated upstream
        // Y-Axis Labels configuration
=======
>>>>>>> Stashed changes
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (value, _) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: intervalX,
<<<<<<< Updated upstream
            getTitlesWidget: (value, meta) {
=======
            getTitlesWidget: (value, _) {
>>>>>>> Stashed changes
              if (value == minX || value == maxX)
                return const SizedBox.shrink();
              return Text(
                '${value.toInt()}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
<<<<<<< Updated upstream
          bottom: BorderSide(color: Colors.white24, width: 1),
          left: BorderSide(color: Colors.white24, width: 1),
=======
          bottom: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
>>>>>>> Stashed changes
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
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withValues(alpha: 0.15),
                lineColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
