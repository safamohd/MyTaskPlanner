import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil {
  static const TAG = "ShredPrefUtil:";

  static const _kFirstOpen = "firstOpen";

  static SharedPreferences _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// returns the stored first open value from the persistent storage
  static bool get isFirstOpen {
    print("$TAG isFirstOpen:: getting stored first open value");
    try {
      return _preferences.getBool(_kFirstOpen);
    } catch (e) {
      print('$TAG [Error] isFirstOpen:: $e');
      return true;
    }
  }

  /// update the stored firstOpen value in the persistent storage
  static Future<bool> setFirstOpen(bool firstOpen) {
    print("$TAG setFirstOpen:: updating firstOpen value");
    try {
      return _preferences.setBool(_kFirstOpen, firstOpen);
    } catch (e) {
      print('$TAG [Error] setFirstOpen:: $e');
      return null;
    }
  }
}
