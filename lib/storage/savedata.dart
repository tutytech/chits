import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString('token');
  }

  static Future<int?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('userId');
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString('userEmail');
  }

  static Future<String?> getRole() async {
    final prefs = await _getPrefs();
    return prefs.getString('code');
  }

  static Future<int?> getOrgId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('orgId');
  }

  static Future<String?> getUserName() async {
    final prefs = await _getPrefs();
    return prefs.getString('userName');
  }
}
