import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/favorites_service.dart';
import 'article_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Article> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final article = _favorites[index];
          return ListTile(
            title: Text(article.title),
            subtitle: Text(article.description),
            leading: article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : null,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(article: article),
                ),
              );
              _loadFavorites(); // Refresh the favorites list
            },
          );
        },
      ),
    );
  }
}
