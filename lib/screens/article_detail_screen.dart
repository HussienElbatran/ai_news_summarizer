import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../services/favorites_service.dart';
import '../services/summarization_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final SummarizationService _summarizationService = SummarizationService();
  bool _isSummarizing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
        actions: [
          Consumer<FavoritesService>(
            builder: (context, favoritesService, child) {
              final isFavorite = favoritesService.isFavorite(widget.article);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  favoritesService.toggleFavorite(widget.article);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.article.title, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Text(widget.article.publishedAt, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 16),
            if (widget.article.imageUrl.isNotEmpty)
              Image.network(widget.article.imageUrl, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(widget.article.description),
            SizedBox(height: 24),
            if (widget.article.summary != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary:', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  Text(widget.article.summary!),
                ],
              )
            else
              ElevatedButton(
                onPressed: _isSummarizing ? null : _summarizeArticle,
                child: _isSummarizing
                    ? CircularProgressIndicator()
                    : Text('Generate Summary'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _summarizeArticle() async {
    setState(() {
      _isSummarizing = true;
    });

    try {
      final summary = await _summarizationService.summarizeText(widget.article.description);
      setState(() {
        widget.article.summary = summary;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate summary. Please try again.')),
      );
    } finally {
      setState(() {
        _isSummarizing = false;
      });
    }
  }
}
