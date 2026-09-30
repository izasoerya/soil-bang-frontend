import 'package:bang_soil/views/widgets/molecules/sensor_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SensorHeaderSection Tests', () {
    testWidgets('renders Sample ID, last fetch time, and battery percentage',
        (tester) async {
      final testTime = DateTime(2026, 9, 30, 14, 30, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorHeaderSection(
              battery: 88,
              createdAt: testTime,
              sampleId: 7,
              lastFetchTime: testTime,
            ),
          ),
        ),
      );

      expect(find.text('Sample #7'), findsOneWidget);
      expect(find.text('14:30:45'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
    });

    testWidgets('renders fallback when sampleId is null', (tester) async {
      final testTime = DateTime(2026, 9, 30, 10, 15, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorHeaderSection(
              battery: 45,
              createdAt: testTime,
            ),
          ),
        ),
      );

      expect(find.text('Sample #-'), findsOneWidget);
      expect(find.text('10:15:00'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
    });
  });
}
