import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_education_centre/pages/auth/login_page.dart';
import 'package:star_education_centre/utils/logout_button.dart';

void main() {
  testWidgets('LogoutButton navigates to login screen on logout',
      (WidgetTester tester) async {
    // Rebuild the widget to check for changes
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LogoutButton(),
        ),
        routes: {'/login': (context) => const LoginPage()},
      ),
    );

    // Verify that the button is displayed
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

    // Tap the button to initiate logout
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    //Tap the confirmation box
    await tester.tap(find.text("Confirm"));
    await tester.pumpAndSettle();

    // Verify that the app navigates to the login screen
    expect(find.text('Login Form!'), findsOneWidget);
  });
}
