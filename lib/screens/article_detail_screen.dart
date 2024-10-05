// lib/screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../services/favorites_service.dart';
import '../services/gemini_service.dart'; // Import the GeminiService

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isSummarizing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
        actions: [
          Consumer<FavoritesService>(
            builder: (context, favoritesService, child) {
              final isFavorite = favoritesService.isFavorite(widget.article);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  favoritesService.toggleFavorite(widget.article);
                  setState(() {}); // Update the UI after toggling favorite
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
            // Article Title
            Text(
              widget.article.title,
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            // Publication Date
            Text(
              widget.article.publishedAt,
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            // Article Image
            if (widget.article.imageUrl.isNotEmpty)
              Image.network(
                widget.article.imageUrl,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            // Article Description
            Text(
              widget.article.description,
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: 24),
            // Summary Section or Generate Summary Button
            if (widget.article.summary != null &&
                widget.article.summary!.isNotEmpty)
              _buildSummarySection(widget.article.summary!, isDarkMode)
            else
              _buildSummarizeButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the Summary Section when a summary exists.
  Widget _buildSummarySection(String summary, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            summary,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Builds the Summarize Button when no summary exists.
  Widget _buildSummarizeButton() {
    return ElevatedButton(
      onPressed: _isSummarizing ? null : _summarizeArticle,
      child: _isSummarizing
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.0,
        ),
      )
          : Text('Generate Summary'),
    );
  }

  /// Handles the summarization process using GeminiService.
  Future<void> _summarizeArticle() async {
    setState(() {
      _isSummarizing = true;
    });

    try {
      // Access GeminiService via Provider
      final geminiService =
      Provider.of<GeminiService>(context, listen: false);

      // Define a prompt for summarization using the article's description
      final prompt =
          'Summarize the following article:\n\n${widget.article.description}';

      // Generate summary using GeminiService
      final summary = await geminiService.generateContent(prompt);

      setState(() {
        widget.article.summary = summary;
      });

      // Persist the updated article in Hive with URL as the key
      final articlesBox = Hive.box<Article>('articles');
      articlesBox.put(widget.article.url, widget.article); // Use URL as key

      // Inform the user that the summary was generated successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Summary generated successfully!')),
      );
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate summary. Please try again.')),
      );
      print('Error generating summary: $e');
    } finally {
      setState(() {
        _isSummarizing = false;
      });
    }
  }
}
