// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/news_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onLanguageChanged; // Callback for language change

  const SettingsScreen({
    Key? key,
    required this.onThemeChanged,
    required this.onCategoryChanged,
    required this.onLanguageChanged, // Accept the callback function
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _preferencesBox;
  String _selectedCategory = 'general';
  bool _isDarkMode = false;
  String _selectedLanguage = 'en'; // Default language (English)

  @override
  void initState() {
    super.initState();
    _preferencesBox = Hive.box('preferences');
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _selectedCategory = _preferencesBox.get('category', defaultValue: 'general');
      _isDarkMode = _preferencesBox.get('darkMode', defaultValue: false);
      _selectedLanguage = _preferencesBox.get('language', defaultValue: 'en'); // Load the selected language
    });
  }

  void _savePreferences() {
    _preferencesBox.put('category', _selectedCategory);
    _preferencesBox.put('darkMode', _isDarkMode);
    _preferencesBox.put('language', _selectedLanguage); // Save the language

    // Notify HomeScreen about the category and language changes
    widget.onCategoryChanged(_selectedCategory);
    widget.onLanguageChanged(_selectedLanguage); // Notify HomeScreen of language change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Preferred Category'),
            trailing: DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                  _savePreferences();
                }
              },
              items: ['general', 'business', 'technology', 'sports', 'entertainment', 'health']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              _savePreferences();
              widget.onThemeChanged(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: Text('Preferred Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  _savePreferences();
                }
              },
              items: {
                'en': 'English',
                'ar': 'Arabic',
                'fr': 'French',
                'es': 'Spanish',
                'zh': 'Chinese',
              }.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
