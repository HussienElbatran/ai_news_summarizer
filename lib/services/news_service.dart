import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/article.dart';

class NewsService extends ChangeNotifier {
  final String _apiKey = 'YOUR_API_KEY_HERE'; // Replace with your actual API key
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
  }

  void _loadPreferredCategory() {
    final prefs = Hive.box('preferences');
    _category = prefs.get('category', defaultValue: 'general');
  }

  Future<void> getTopHeadlines({String? category}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/top-headlines?country=us&category=${category ?? _category}&apiKey=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articlesJson = data['articles'];
        await _articlesBox.clear();

        for (var jsonArticle in articlesJson) {
          final article = Article.fromJson(jsonArticle);
          await _articlesBox.add(article);
        }
      } else {
        _error = 'Failed to load news. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading news: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateCategory(String newCategory) {
    if (_category != newCategory) {
      _category = newCategory;
      final prefs = Hive.box('preferences');
      prefs.put('category', newCategory);
      getTopHeadlines();
    }
  }

  List<Article> getArticles() {
    return _articlesBox.values.toList();
  }

  Future<void> refreshNews() async {
    await getTopHeadlines();
  }
}
