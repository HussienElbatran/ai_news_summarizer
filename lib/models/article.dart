// lib/models/article.dart

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'article.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final String publishedAt;

  @HiveField(5)
  String? summary;

  @HiveField(6)
  final String category;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    this.summary,
    required this.category,
  });

  /// Factory method to create an Article from JSON data
  factory Article.fromJson(Map<String, dynamic> json, String category) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      category: category,
    );
  }

  /// Returns the time since the article was published in a readable format
  String get timeSincePublished {
    final date = DateTime.tryParse(publishedAt)?.toLocal();
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}
