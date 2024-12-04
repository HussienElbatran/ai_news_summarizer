// lib/screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../services/favorites_service.dart';
import '../services/gemini_service.dart'; // Import the GeminiService

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final String selectedLanguage; // Add the selected language

  const ArticleDetailScreen({Key? key, required this.article, required this.selectedLanguage}) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isSummarizing = false;
  String _currentLanguage = ''; // Track the currently selected language
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'zh', 'name': 'Chinese'},
  ];

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.selectedLanguage; // Initialize with the language passed from the previous screen
  }

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
            // Article Image
            if (widget.article.imageUrl.isNotEmpty)
              Image.network(
                widget.article.imageUrl,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            // Article Title
            Text(
              widget.article.title,
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            // Publication Date
            Text(
              widget.article.timeSincePublished,
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            // Language Selection Dropdown
            _buildLanguageDropdown(),
            SizedBox(height: 16),
            // Article Description
            Text(
              widget.article.description,
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: 24),
            // Summary Section or Generate Summary Button
            if (widget.article.summary != null && widget.article.summary!.isNotEmpty)
              _buildSummarySection(widget.article.summary!, isDarkMode)
            else
              _buildSummarizeButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the Language Selection Dropdown
  Widget _buildLanguageDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select Summary Language:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        DropdownButton<String>(
          value: _currentLanguage,
          onChanged: (String? newLanguage) {
            if (newLanguage != null && newLanguage != _currentLanguage) {
              setState(() {
                _currentLanguage = newLanguage;
                widget.article.summary = null; // Clear existing summary
              });
            }
          },
          items: _languages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang['code'],
              child: Text(lang['name']!),
            );
          }).toList(),
        ),
      ],
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
            border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            summary,
            style: TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _summarizeArticle(), // Re-summarize in selected language
          child: Text('summarize in ${_languages.firstWhere((lang) => lang['code'] == _currentLanguage)['name']}'),
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
      final geminiService = Provider.of<GeminiService>(context, listen: false);

      // Define a prompt for summarization using the article's description
      final prompt = 'Summarize the following article:\n\n${widget.article.description}';

      // Generate summary using GeminiService in the selected language
      final summary = await geminiService.generateContent(prompt, _currentLanguage);

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
