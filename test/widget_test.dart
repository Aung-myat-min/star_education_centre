import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_education_centre/utils/confirmation_box.dart';

class _WidgetTest1 extends StatefulWidget {
  const _WidgetTest1({super.key});

  @override
  State<_WidgetTest1> createState() => _WidgetTest1State();
}

class _WidgetTest1State extends State<_WidgetTest1> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ElevatedButton(
            onPressed: () async {
              bool result = await showConfirmationDialog(
                  context, 'Confirm Action', 'Are you sure?');
              print('Dialog result: $result');
            },
            child: const Text('Show Dialog'),
          );
        },
      ),
    );
  }
}

void main() {
  testWidgets('Test showConfirmationDialog', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      const _WidgetTest1(),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify if the dialog appears with the correct title and content
    expect(find.text('Confirm Action'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);

    // Test tapping the 'Cancel' button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Show Dialog'), findsOneWidget);

    // Tap the button again to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Test tapping the 'Confirm' button
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Show Dialog'), findsOneWidget);
  });
}
