// lib/services/gemini_service.dart

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService with ChangeNotifier {
  final String _apiKey = 'AIzaSyDL2nQUWL5jQgp9Kwo2oHtHmm-fV7574oM'; // Add your API key directly

  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
    model: 'gemini-1.5-flash-8b',
    apiKey: 'AIzaSyDL2nQUWL5jQgp9Kwo2oHtHmm-fV7574oM', // Add the same API key here
  );

  /// Generates a summary based on the provided prompt and language.
  ///
  /// [prompt] - The text or URL of the news article to summarize.
  /// [language] - The language in which the summary should be generated (e.g., 'en' for English).
  ///
  /// Returns a [String] containing the summary or an error message.
  Future<String> generateContent(String prompt, String language) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key is not set.');
    }

    final systemInstructions = 'You are an AI assistant. Provide concise, accurate, and neutral summaries in $language without personal opinions.\n\n';

    final combinedPrompt = systemInstructions + prompt;

    try {
      final response = await _model.generateContent([Content.text(combinedPrompt)]);
      return response.text?.trim() ?? 'No content generated.';
    } catch (e) {
      if (kDebugMode) {
        print('Error generating content: $e');
      }
      return 'Failed to generate content.';
    }
  }
}
