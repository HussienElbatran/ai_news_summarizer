// lib/screens/home_screen.dart

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
  String _selectedCategory = 'general'; // Hold selected category
  String _selectedLanguage = 'en'; // Hold selected language (default English)
  final ScrollController _scrollController = ScrollController(); // Add a ScrollController

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsService>(context, listen: false).getTopHeadlines();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
          !Provider.of<NewsService>(context, listen: false).isLoading) {
        Provider.of<NewsService>(context, listen: false).loadMoreArticles(); // Load more articles when scrolled to bottom
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller when screen is disposed
    super.dispose();
  }

  /// Update the selected category from settings
  void _updateCategory(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
    Provider.of<NewsService>(context, listen: false).updateCategory(newCategory);
  }

  /// Update the selected language from settings
  void _updateLanguage(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  // The _buildNewsList method to display the news articles
  Widget _buildNewsList() {
    return Consumer<NewsService>(
      builder: (context, newsService, child) {
        if (newsService.isLoading && newsService.getArticles().isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (newsService.error.isNotEmpty) {
          return Center(child: Text(newsService.error)); // Display user-friendly error message
        }

        // Apply filtering to remove articles with [Removed] in title/description or empty content
        final articles = newsService.getArticles().where((article) {
          return article.title.isNotEmpty &&
              article.description.isNotEmpty &&
              !article.title.contains('[Removed]') &&
              !article.description.contains('[Removed]');
        }).toList();

        if (articles.isEmpty) {
          return const Center(child: Text('No articles available'));
        }

        return RefreshIndicator(
          onRefresh: () => newsService.refreshNews(), // Call the refreshNews method
          child: ListView.builder(
            controller: _scrollController, // Attach the ScrollController to the ListView
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(
                        article: article,
                        selectedLanguage: _selectedLanguage, // Pass the selected language
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // News Image at the top
                        if (article.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          article.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Text(
                          article.timeSincePublished,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          article.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _getCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildNewsList();
      case 1:
        return const FavoritesScreen();
      case 2:
        return SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onCategoryChanged: _updateCategory, // Pass category callback
          onLanguageChanged: _updateLanguage, // Pass language callback
        );
      default:
        return _buildNewsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI News Summarizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<NewsService>(context, listen: false)
                .refreshNews(),
          ),
        ],
      ),
      body: _getCurrentTab(),
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
