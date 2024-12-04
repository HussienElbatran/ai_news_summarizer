import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/article.dart';

class NewsService extends ChangeNotifier {
  final String _apiKey = 'bafacaf2ea904251977030b4e299b225'; // Replace with your actual API key
  final String _baseUrl = 'https://newsapi.org/v2';
  final Box<Article> _articlesBox = Hive.box<Article>('articles');

  bool _isLoading = false;
  String _error = '';
  String _category = 'general';

  bool get isLoading => _isLoading;
  String get error => _error;
  String get category => _category;

  NewsService() {
    _loadPreferredCategory();
    getTopHeadlines(); // Fetch headlines on initialization
  }

  /// Loads the preferred news category from Hive preferences.
  void _loadPreferredCategory() {
    final prefs = Hive.box('preferences');
    _category = prefs.get('category', defaultValue: 'general');
  }

  /// Fetches top headlines from the News API based on the selected category.
  Future<void> getTopHeadlines({String? category}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final fetchCategory = category ?? _category;

      // Construct the API URL with the specified or preferred category
      final url = Uri.parse(
        '$_baseUrl/top-headlines?country=us&category=$fetchCategory&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articlesJson = data['articles'];

        // **Important Changes Start Here**

        // **1. Remove Clearing of Articles Box**
        // Previously, the articles box was being cleared, which removed all stored articles,
        // including those marked as favorites. Removing this line prevents loss of favorite articles.
        // await _articlesBox.clear();

        // **2. Store Articles with URL as Key**
        // Instead of using `add`, which assigns an auto-incremented key, use `put` with the article's URL.
        // This ensures each article is uniquely identified and prevents Hive errors when managing favorites.
        for (var jsonArticle in articlesJson) {
          final article = Article.fromJson(jsonArticle, fetchCategory);

          if (article.url.isNotEmpty) {
            await _articlesBox.put(article.url, article);
          }
        }

        // **Important Changes End Here**
      } else {
        _error = 'Failed to load news. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading news: $e';
      if (kDebugMode) {
        print('Error loading news: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the news category and fetches new headlines.
  void updateCategory(String newCategory) {
    if (_category != newCategory) {
      _category = newCategory;
      final prefs = Hive.box('preferences');
      prefs.put('category', newCategory);
      getTopHeadlines(); // Fetch headlines for the new category
    }
  }

  /// Retrieves articles from the 'articles' box filtered by the current category.
  List<Article> getArticles() {
    return _articlesBox.values
        .where((article) => article.category == _category)
        .toList();
  }

  /// Refreshes the news by fetching the latest headlines for the current category.
  Future<void> refreshNews() async {
    await getTopHeadlines();
  }
}