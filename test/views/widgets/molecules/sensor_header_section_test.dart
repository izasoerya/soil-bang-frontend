import 'package:bang_soil/views/widgets/molecules/sensor_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SensorHeaderSection Tests', () {
    testWidgets('renders sample index, time, and LED label', (tester) async {
      final testTime = DateTime(2026, 9, 30, 14, 30, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorHeaderSection(
              battery: 88,
              createdAt: testTime,
              sampleIndex: 2,
              sampleCount: 3,
              ledLabel: 'IR LED',
              lastFetchTime: testTime,
            ),
          ),
        ),
      );

      expect(find.text('Sample #2/3'), findsOneWidget);
      expect(find.text('14:30:45'), findsOneWidget);
      expect(find.text('IR LED'), findsOneWidget);
    });

    testWidgets('renders default sample index and LED label', (tester) async {
      final testTime = DateTime(2026, 9, 30, 10, 15, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SensorHeaderSection(createdAt: testTime)),
        ),
      );

      expect(find.text('Sample #1/3'), findsOneWidget);
      expect(find.text('Unknown LED'), findsOneWidget);
    });
  });
}
