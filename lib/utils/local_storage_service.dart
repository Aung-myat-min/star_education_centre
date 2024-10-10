import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Method to save login status and expiration date
  Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('logged', isLoggedIn);

    // Set expiration date (for example, 7 days from now)
    DateTime expirationDate = DateTime.now().add(const Duration(days: 30));
    prefs.setString('expiration_date', expirationDate.toIso8601String());
  }

  // Method to check if the login status is still valid
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool? logged = prefs.getBool('logged');
    String? expirationDateStr = prefs.getString('expiration_date');

    if (logged == true && expirationDateStr != null) {
      DateTime expirationDate = DateTime.parse(expirationDateStr);
      if (DateTime.now().isBefore(expirationDate)) {
        return true;
      } else {
        await clearLoginStatus();
        return false;
      }
    }
    return false;
  }

  // Method to clear login status
  Future<void> clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('logged');
    prefs.remove('expiration_date');
  }
}
