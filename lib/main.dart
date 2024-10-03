import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'services/news_service.dart';
import 'models/article.dart';
import 'article_detail_screen.dart';
import 'theme.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  await Hive.openBox<Article>('articles');
  await Hive.openBox('preferences');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await Hive.openBox('preferences');
    final isDarkMode = prefs.get('darkMode', defaultValue: false);
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI News Summarizer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return HomeScreen(onThemeChanged: _changeTheme);
          }
          return AuthScreen();
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const HomeScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final NewsService _newsService = NewsService();
  late Box<Article> _articlesBox;
  late Box _preferencesBox;
  String _selectedCategory = 'general';

  @override
  void initState() {
    super.initState();
    _articlesBox = Hive.box<Article>('articles');
    _preferencesBox = Hive.box('preferences');
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _selectedCategory = _preferencesBox.get('category', defaultValue: 'general');
    });
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      await _newsService.getTopHeadlines(category: _selectedCategory);
      setState(() {});
    } catch (e) {
      print('Error loading news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news. Please try again later.')),
      );
    }
  }

  Widget _buildNewsList() {
    return ValueListenableBuilder(
      valueListenable: _articlesBox.listenable(),
      builder: (context, Box<Article> box, _) {
        if (box.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: _loadNews,
          child: ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final article = box.getAt(index)!;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(article.title, style: Theme.of(context).textTheme.headline6),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(article.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Text(article.publishedAt, style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  leading: article.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      article.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI News Summarizer'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _buildNewsList(),
          FavoritesScreen(),
          SettingsScreen(onThemeChanged: widget.onThemeChanged),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}