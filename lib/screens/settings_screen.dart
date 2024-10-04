import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/news_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _preferencesBox;
  String _selectedCategory = 'general';
  bool _isDarkMode = false;

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
    });
  }

  void _savePreferences() {
    _preferencesBox.put('category', _selectedCategory);
    _preferencesBox.put('darkMode', _isDarkMode);
    Provider.of<NewsService>(context, listen: false).updateCategory(_selectedCategory);
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
        ],
      ),
    );
  }
}
