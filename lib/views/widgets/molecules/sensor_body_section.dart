import 'package:bang_soil/models/sensor.dart';
import 'package:bang_soil/theme/app_theme.dart';
import 'package:bang_soil/views/widgets/atoms/sensor_value_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorBodySection extends StatefulWidget {
  const SensorBodySection({super.key, required this.sample});

  final SensorSample sample;

  @override
  State<SensorBodySection> createState() => _SensorBodySectionState();
}

class _SensorBodySectionState extends State<SensorBodySection> {
  int? _selectedLedType;

  @override
  Widget build(BuildContext context) {
    final sample = widget.sample;
    final selectedType = _selectedLedType;
    final sensor = selectedType == null
        ? sample.selectedReading
        : sample.readings[selectedType] ?? sample.selectedReading;
    if (sensor == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Waiting for LED sensor data...'),
      );
    }
    final allSpots = sensor.spectralChannels.entries.map((entry) {
      final wavelength = double.parse(entry.key.replaceAll(' nm', ''));
      return FlSpot(wavelength, entry.value);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

    final visibleSpots = allSpots.where((s) => s.x <= 705).toList();
    final irSpots = allSpots.where((s) => s.x >= 730).toList();
    final hPad = MediaQuery.of(context).size.width * 0.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
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
              Container(
                height: 38,
                padding: const EdgeInsets.only(left: 12, right: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: sensor.ledType,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                    dropdownColor: AppColors.surfaceCard,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    items: sample.orderedReadings
                        .map(
                          (reading) => DropdownMenuItem(
                            value: reading.ledType,
                            child: Text(
                              SensorLedType.fromValue(reading.ledType).label,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLedType = value),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
        ),

        const SizedBox(height: 20),

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

        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              collapsedBackgroundColor: AppColors.surface,
              backgroundColor: AppColors.surface,
              iconColor: AppColors.primary,
              collapsedIconColor: AppColors.textSecondary,
              title: const Text(
                'Raw Channel Matrix',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'μW/cm²',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: sensor.spectralChannels.length,
                  itemBuilder: (context, index) {
                    final entry = sensor.spectralChannels.entries.elementAt(
                      index,
                    );
                    return SensorValueCard(entry: entry);
                  },
                ),
              ],
            ),
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
            getTitlesWidget: (value, _) {
              if (value == minX || value == maxX) {
                return const SizedBox.shrink();
              }
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
          bottom: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
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
