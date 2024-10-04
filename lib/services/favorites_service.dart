import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/article.dart';

class FavoritesService extends ChangeNotifier {
  final Box<Article> _favoritesBox = Hive.box<Article>('favorites');

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
    await _favoritesBox.put(article.url, article);
  }

  Future<void> removeFavorite(Article article) async {
    await _favoritesBox.delete(article.url);
  }

  List<Article> getFavorites() {
    return _favoritesBox.values.toList();
  }

  bool isFavorite(Article article) {
    return _favoritesBox.containsKey(article.url);
  }
}
