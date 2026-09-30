import 'package:bang_soil/views/widgets/atoms/modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppModal Widget Tests', () {
    testWidgets('renders confirmation modal with proper texts and triggers actions',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await AppModal.showConfirmation(
                    context: context,
                    title: 'Sampling Confirmation',
                    message: 'Are you sure you want to perform data sampling?',
                    confirmText: 'Confirm',
                    cancelText: 'Cancel',
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Open confirmation dialog
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Sampling Confirmation'), findsOneWidget);
      expect(
        find.text('Are you sure you want to perform data sampling?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Sampling Confirmation'), findsNothing);
    });

    testWidgets('renders success modal with proper texts and close action',
        (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppModal.showSuccess(
                    context: context,
                    title: 'Sampling Successful',
                    message: 'Success taking data',
                    closeText: 'Close',
                    onClose: () => closed = true,
                  );
                },
                child: const Text('Open Success'),
              ),
            ),
          ),
        ),
      );

      // Open success dialog
      await tester.tap(find.text('Open Success'));
      await tester.pumpAndSettle();

      expect(find.text('Sampling Successful'), findsOneWidget);
      expect(find.text('Success taking data'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(find.text('Sampling Successful'), findsNothing);
    });

    testWidgets('uses white text in dark mode and black text in light mode',
        (tester) async {
      // Test dark mode
      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: const Scaffold(
              body: AppModal(
                title: 'Dark Mode Title',
                message: 'Dark Mode Message',
              ),
            ),
          ),
        ),
      );

      final titleDark = tester.widget<Text>(find.text('Dark Mode Title'));
      expect(titleDark.style?.color, Colors.white);

      // Test light mode
      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ThemeData(brightness: Brightness.light),
            child: const Scaffold(
              body: AppModal(
                title: 'Light Mode Title',
                message: 'Light Mode Message',
              ),
            ),
          ),
        ),
      );

      final titleLight = tester.widget<Text>(find.text('Light Mode Title'));
      expect(titleLight.style?.color, Colors.black);
    });
  });
}
