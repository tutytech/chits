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

  static Future<String?> getLastScreen() async {
    final prefs = await _getPrefs();
    return prefs.getString('lastScreen');
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

  static Future<int?> getcustomerId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('customerId');
  }

  static Future<int?> getId() async {
    final prefs = await _getPrefs();
    return prefs.getInt('id');
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

  static Future<void> setbranchname(String branchName) async {
    final prefs = await _getPrefs();
    await prefs.setString('branchName', branchName);
  }

  static Future<String?> getbranchname() async {
    final prefs = await _getPrefs();
    return prefs.getString('branchName');
  }

  static Future<void> setrights(String rights) async {
    final prefs = await _getPrefs();
    await prefs.setString('rights', rights);
  }

  static Future<void> setusername(String username) async {
    final prefs = await _getPrefs();
    await prefs.setString('userName', username);
  }

  static Future<void> setpassword(String password) async {
    final prefs = await _getPrefs();
    await prefs.setString('password', password);
  }

  static Future<void> setid(int id) async {
    final prefs = await _getPrefs();
    await prefs.setInt('id', id);
  }

  static Future<void> setprofile(String profile) async {
    final prefs = await _getPrefs();
    await prefs.setString('profileUrl', profile);
  }

  static Future<String?> getrights() async {
    final prefs = await _getPrefs();
    return prefs.getString('rights');
  }

  static Future<String?> getprofile() async {
    final prefs = await _getPrefs();
    return prefs.getString('profileUrl');
  }
}
