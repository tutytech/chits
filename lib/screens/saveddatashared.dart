import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  // Private method to get SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  // Check if the user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Save login state
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _getPrefs();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Get user ID
  static Future<int?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('staffId');
  }

  // Save user ID
  static Future<void> setUserId(int userId) async {
    final prefs = await _getPrefs();
    await prefs.setInt('staffId', userId);
  }

  // Save company ID
  static Future<void> saveCompanyId(String companyId) async {
    final prefs = await _getPrefs();
    await prefs.setString('companyId', companyId);
  }

  // Get company ID
  static Future<String?> getCompanyId() async {
    final prefs = await _getPrefs();
    return prefs.getString('companyId');
  }

  // Save company name
  static Future<void> saveCompanyName(String companyName) async {
    final prefs = await _getPrefs();
    await prefs.setString('companyName', companyName);
  }

  // Get company name
  static Future<String?> getCompanyName() async {
    final prefs = await _getPrefs();
    return prefs.getString('companyName');
  }

  // Save address
  static Future<void> saveAddress(String address) async {
    final prefs = await _getPrefs();
    await prefs.setString('address', address);
  }

  // Get address
  static Future<String?> getAddress() async {
    final prefs = await _getPrefs();
    return prefs.getString('address');
  }

  // Save email
  static Future<void> saveEmail(String email) async {
    final prefs = await _getPrefs();
    await prefs.setString('email', email);
  }

  // Get email
  static Future<String?> getEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString('email');
  }

  // Save phone number
  static Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await _getPrefs();
    await prefs.setString('phoneNumber', phoneNumber);
  }

  // Get phone number
  static Future<String?> getPhoneNumber() async {
    final prefs = await _getPrefs();
    return prefs.getString('phoneNumber');
  }

  // Clear all preferences
  static Future<void> clearPreferences() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  static Future<void> saveSmsId(String smsId) async {
    final prefs = await _getPrefs();
    await prefs.setString('smsId', smsId);
  }

  // Get SMS ID
  static Future<String?> getSmsId() async {
    final prefs = await _getPrefs();
    return prefs.getString('smsId');
  }

  static Future<void> saveSmsbranchdrop(String branchName) async {
    final prefs = await _getPrefs();
    await prefs.setString('branchName', branchName);
  }

  // Get SMS ID
  static Future<String?> getSmsbranchdrop() async {
    final prefs = await _getPrefs();
    return prefs.getString('branchName');
  }
}
