import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../services/favorites_service.dart';
import 'article_detail_screen.dart';
import 'package:hive/hive.dart';  // Add this import to retrieve the selected language

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, child) {
        final favorites = favoritesService.getFavorites();

        // Retrieve the selected language from Hive (or from a provider, if you're using one)
        final selectedLanguage = Hive.box('preferences').get('language', defaultValue: 'en');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorites'),
          ),
          body: favorites.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final article = favorites[index];
              return ListTile(
                title: Text(article.title),
                subtitle: Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: article.imageUrl.isNotEmpty
                    ? Image.network(
                  article.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : null,
                trailing: IconButton(
                  icon: Icon(
                    favoritesService.isFavorite(article)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favoritesService.isFavorite(article)
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () {
                    favoritesService.toggleFavorite(article);
                  },
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(
                        article: article,
                        selectedLanguage: selectedLanguage, // Pass the selected language here
                      ),
                    ),
                  );
                  // No need to reload favorites; Consumer will rebuild when favorites change
                },
              );
            },
          ),
        );
      },
    );
  }
}
