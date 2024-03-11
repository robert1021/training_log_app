import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  // keys

  // General
  static const _keyDarkMode = 'darkMode';
  static const _keyScreenOn = 'screenOn';
  // Vibration
  static const _keyVibrate = 'buttonPressedVibrate';

  // google auth
  static const _keyAuthHeader = 'authHeader';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Used to store dark mode toggle status.
  static Future setDarkModeToggle(bool isOn) async {
    await _preferences.setBool(_keyDarkMode, isOn);
  }

  // Get the stored dark mode toggle status.
  static bool? getDarkMode() => _preferences.getBool(_keyDarkMode);

  // Used to store screen on status.
  static Future setScreenOn(bool isOn) async {
    await _preferences.setBool(_keyScreenOn, isOn);
  }

  // Get the stored screen on status.
  static bool? getScreenOn() => _preferences.getBool(_keyScreenOn);

  // Used to store vibrate on/off.
  static Future setVibrate(bool isOn) async {
    await _preferences.setBool(_keyVibrate, isOn);
  }

  // Get the stored vibrate status
  static bool? getVibrate() => _preferences.getBool(_keyVibrate);

  // Used to store google auth header.
  static Future setGoogleAuthHeader(Map<String, String> authHeader) async {
    List<String> items = [];
    for (var value in authHeader.values) {
      items.add(value);
    }
    await _preferences.setStringList(_keyAuthHeader, items);
  }

  // Get the stored Google auth header.
  static Map<String, String> getGoogleAuthHeader() {
    return {
      'Authorization': _preferences.getStringList(_keyAuthHeader)![0],
      'X-Goog-AuthUser': _preferences.getStringList(_keyAuthHeader)![1]
    };
  }
}
