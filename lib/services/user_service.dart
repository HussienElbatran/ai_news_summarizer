import 'package:hive/hive.dart';

class UserService {
  final Box _preferencesBox = Hive.box('preferences');

  Future<Map<String, dynamic>> getPreferences() async {
    return {
      'preferredCategory': _preferencesBox.get('category', defaultValue: 'general'),
      'isDarkMode': _preferencesBox.get('darkMode', defaultValue: false),
    };
  }

  Future<void> savePreferences(String category, bool isDarkMode) async {
    await _preferencesBox.put('category', category);
    await _preferencesBox.put('darkMode', isDarkMode);
  }
}
