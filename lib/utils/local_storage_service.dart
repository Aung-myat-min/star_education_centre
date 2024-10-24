import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  // Open the box
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('starEducation');
  }

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    var box = Hive.box('starEducation');
    await box.put('logged', isLoggedIn);

    DateTime expirationDate = DateTime.now().add(const Duration(days: 30));
    await box.put('expiration_date', expirationDate.toIso8601String());
  }

  Future<bool> isLoggedIn() async {
    var box = Hive.box('starEducation');
    bool? logged = box.get('logged');
    String? expirationDateStr = box.get('expiration_date');

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

  Future<void> clearLoginStatus() async {
    var box = Hive.box('starEducation');
    await box.delete('logged');
    await box.delete('expiration_date');
  }
}
