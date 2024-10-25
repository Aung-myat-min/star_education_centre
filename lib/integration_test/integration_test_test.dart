import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_education_centre/constants.dart';
import 'package:star_education_centre/main.dart' as app;

class IntegrationTest {
  // Function to run the login test
  static Future<void> loginWithValidCredentials(WidgetTester tester) async {
    // Start the app
    await app.main();
    await tester.pumpAndSettle();

    // Verify we are on the login page
    expect(find.text('Login Form!'), findsOneWidget);
    expect(find.text('Star Education Centre'), findsOneWidget);

    // Find email and password fields and enter valid credentials
    var emailField = find.byType(TextFormField).at(0);
    var passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, loginEmail);
    await tester.enterText(passwordField, loginPassword);

    // Tap the login button
    var loginButton = find.byKey(const Key('loginButton'));
    await tester.tap(loginButton);

    // Rebuild the widget after the state has changed
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify if it navigated to the home page
    expect(find.text('Most Popular Courses'), findsOneWidget);
  }

  static Future<void> navigateToStudentPage(WidgetTester tester) async {
    print("=== Integration Testing for Navigating to Student Page ===");
    await tester.tap(find.byIcon(Icons.people_alt));
    await tester.pumpAndSettle(Duration(seconds: 2));

    expect(find.text("Manage Students"), findsOneWidget);
  }

  static Future<void> navigateToCoursePage(WidgetTester tester) async {
    print("=== Integration Testing for Navigating to Course Page ===");
    // Navigate to the courses page
    await tester.tap(find.byIcon(Icons.book_rounded));
    await tester.pumpAndSettle(Duration(seconds: 2));

    expect(find.text("Create Course Here!"), findsOneWidget);
  }
}
