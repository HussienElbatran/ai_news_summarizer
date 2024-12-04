import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/article.dart';
import 'services/news_service.dart';
import 'services/favorites_service.dart';
import 'services/gemini_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  await Hive.openBox<Article>('articles');
  await Hive.openBox<String>('favorites');
  await Hive.openBox<dynamic>('preferences');
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
    final prefs = Hive.box<dynamic>('preferences');
    final isDarkMode = prefs.get('darkMode', defaultValue: false) as bool;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    final prefs = Hive.box<dynamic>('preferences');
    prefs.put('darkMode', themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _newsService),
        ChangeNotifierProvider.value(value: _favoritesService),
        ChangeNotifierProvider(create: (_) => GeminiService()),
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
