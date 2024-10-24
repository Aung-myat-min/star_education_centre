import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_education_centre/utils/status_snackbar.dart';

class _WidgetTesting2 extends StatefulWidget {
  const _WidgetTesting2({super.key});

  @override
  State<_WidgetTesting2> createState() => _WidgetTesting2State();
}

class _WidgetTesting2State extends State<_WidgetTesting2> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                print("Button Pressed!");
                statusSnackBar(
                    context, SnackBarType.success, 'SnackBar is displayed!');
              },
              child: const Text('Show SnackBar'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('statusSnackBar shows wanted Status Bar',
      (WidgetTester tester) async {
    // Build a basic MaterialApp widget for the test
    await tester.pumpWidget(const _WidgetTesting2());

    expect(find.byType(SnackBar), findsNothing);

    // Tap the button to show the SnackBar
    await tester.tap(find.text('Show SnackBar'));
    await tester.pumpAndSettle();

    // Verify that the SnackBar is displayed
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('SnackBar is displayed!'), findsOneWidget);
  });
}
