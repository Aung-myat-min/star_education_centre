import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:star_education_centre/integration_test/integration_test_test.dart';

// run this test with this command: "flutter drive --driver=test_driver/integration_test.dart --target=lib/integration_test/integration_test.dart -d edge"

void main() {
  // Initialize the integration test
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test for walking through the application', () {
    testWidgets('Login First and Navigate and finally, click something!',
        (WidgetTester tester) async {
      // Call the login test module function
      await IntegrationTest.loginWithValidCredentials(tester);

      await IntegrationTest.navigateToStudentPage(tester);

      await IntegrationTest.navigateToCoursePage(tester);
    });
  });
}
