// lib/models/article.dart

import 'package:hive/hive.dart';

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
  final String category; // New field added

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    this.summary,
    required this.category, // Initialize the new field
  });

  /// Factory method to create an Article from JSON data
  factory Article.fromJson(Map<String, dynamic> json, String category) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      category: category, // Assign the category
    );
  }
}
