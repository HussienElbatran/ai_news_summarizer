import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const HomeScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsService>(context, listen: false).getTopHeadlines();
    });
  }

  Widget _buildNewsList() {
    return Consumer<NewsService>(
      builder: (context, newsService, child) {
        if (newsService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (newsService.error.isNotEmpty) {
          return Center(child: Text(newsService.error));
        }
        final articles = newsService.getArticles();
        if (articles.isEmpty) {
          return Center(child: Text('No articles available'));
        }
        return RefreshIndicator(
          onRefresh: () => newsService.refreshNews(),
          child: ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(article.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Text(article.publishedAt, style: Theme.of(context).textTheme.bodySmall),
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
            onPressed: () => Provider.of<NewsService>(context, listen: false).refreshNews(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildNewsList(),
          FavoritesScreen(),
          SettingsScreen(onThemeChanged: widget.onThemeChanged),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
