// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/article.dart';
import 'screens/home_screen.dart';
import 'services/news_service.dart';
import 'services/favorites_service.dart';
import 'services/gemini_service.dart'; // Import the Gemini service
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ArticleAdapter());

  // Open Hive boxes
  await Hive.openBox<Article>('articles');
  await Hive.openBox<String>('favorites'); // Open as Box<String> for URLs
  await Hive.openBox('preferences');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NewsService _newsService = NewsService();
  final FavoritesService _favoritesService = FavoritesService();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = Hive.box('preferences');
    final isDarkMode = prefs.get('darkMode', defaultValue: false);
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    final prefs = Hive.box('preferences');
    prefs.put('darkMode', themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _newsService),
        ChangeNotifierProvider.value(value: _favoritesService),
        ChangeNotifierProvider(create: (_) => GeminiService()), // Add GeminiService
      ],
      child: MaterialApp(
        title: 'AI News Summarizer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: HomeScreen(onThemeChanged: _changeTheme),
      ),
    );
  }
}
