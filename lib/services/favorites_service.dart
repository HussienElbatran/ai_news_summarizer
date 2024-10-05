// lib/services/favorites_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/article.dart';

class FavoritesService extends ChangeNotifier {
  final Box<String> _favoritesBox = Hive.box<String>('favorites');

  /// Toggles the favorite status of an article.
  Future<void> toggleFavorite(Article article) async {
    print('Toggling favorite for article: ${article.title}');
    final isCurrentlyFavorite = isFavorite(article);
    if (isCurrentlyFavorite) {
      await removeFavorite(article);
      print('Removed from favorites: ${article.title}');
    } else {
      await addFavorite(article);
      print('Added to favorites: ${article.title}');
    }
    notifyListeners();
  }

  /// Adds an article to favorites by storing its URL.
  Future<void> addFavorite(Article article) async {
    if (article.url.isEmpty) {
      print('Cannot add to favorites: Article URL is empty.');
      return;
    }

    final articlesBox = Hive.box<Article>('articles');

    // Ensure the article is stored in the 'articles' box with URL as the key
    if (!articlesBox.containsKey(article.url)) {
      await articlesBox.put(article.url, article);
      print('Article stored in articles box with key: ${article.url}');
    }

    await _favoritesBox.put(article.url, 'true');
    print('Article added to favorites with key: ${article.url}');
  }

  /// Removes an article from favorites by deleting its URL.
  Future<void> removeFavorite(Article article) async {
    await _favoritesBox.delete(article.url);
    print('Article removed from favorites with key: ${article.url}');
  }

  /// Retrieves the list of favorite articles.
  List<Article> getFavorites() {
    final articlesBox = Hive.box<Article>('articles');
    final favoriteUrls = _favoritesBox.keys.cast<String>().toList();
    final favorites = favoriteUrls
        .map((url) => articlesBox.get(url))
        .whereType<Article>()
        .toList();
    print('Fetching favorites: ${favorites.length} items');
    return favorites;
  }

  /// Checks if an article is marked as favorite.
  bool isFavorite(Article article) {
    final favorite = _favoritesBox.containsKey(article.url);
    print('Is article favorite (${article.title}): $favorite');
    return favorite;
  }
}
