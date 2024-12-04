import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/article.dart';

class FavoritesService extends ChangeNotifier {
  final Box<String> _favoritesBox = Hive.box<String>('favorites');
  final Box<Article> _articlesBox = Hive.box<Article>('articles');

  Future<void> toggleFavorite(Article article) async {
    final isCurrentlyFavorite = isFavorite(article);
    if (isCurrentlyFavorite) {
      await removeFavorite(article);
    } else {
      await addFavorite(article);
    }
    notifyListeners();
  }

  Future<void> addFavorite(Article article) async {
    if (article.url.isEmpty) return;
    await _favoritesBox.put(article.url, 'true');
    if (!_articlesBox.containsKey(article.url)) {
      await _articlesBox.put(article.url, article);
    }
  }

  Future<void> removeFavorite(Article article) async {
    await _favoritesBox.delete(article.url);
  }

  List<Article> getFavorites() {
    final favoriteUrls = _favoritesBox.keys.toList();
    return favoriteUrls
        .map((url) => _articlesBox.get(url))
        .whereType<Article>()
        .toList();
  }

  bool isFavorite(Article article) {
    return _favoritesBox.containsKey(article.url);
  }
}