// lib/services/news_service.dart

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
  int _currentPage = 1; // Track the current page for pagination
  List<Article> _articles = [];

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

  Future<void> getTopHeadlines({String? category, int page = 1}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final fetchCategory = category ?? _category;

      // Construct the API URL with category and page
      final url = Uri.parse(
        '$_baseUrl/top-headlines?country=us&category=$fetchCategory&page=$page&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articlesJson = data['articles'];

        // Append the new articles to the existing ones
        _articles = [..._articles, ...articlesJson.map((jsonArticle) => Article.fromJson(jsonArticle, fetchCategory)).toList()];
        _currentPage = page; // Update the current page
      } else {
        _error = 'Failed to load news. Please try again later.'; // User-friendly error message
      }
    } catch (e) {
      // Handle connection or API errors
      _error = 'No internet connection. Please check your connection and try again.'; // User-friendly error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNews() async {
    _articles = []; // Clear the current articles list
    _currentPage = 1; // Reset to the first page
    await getTopHeadlines(); // Fetch fresh news
  }

  Future<void> loadMoreArticles() async {
    await getTopHeadlines(page: _currentPage + 1); // Fetch the next page
  }

  void updateCategory(String newCategory) {
    if (_category != newCategory) {
      _category = newCategory;
      _articles = []; // Clear the articles list when changing category
      _currentPage = 1; // Reset to the first page
      getTopHeadlines(); // Fetch headlines for the new category
    }
  }

  List<Article> getArticles() {
    return _articles;
  }
}
