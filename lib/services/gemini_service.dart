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

  /// Generates a summary based on the provided prompt.
  ///
  /// [prompt] - The text or URL of the news article to summarize.
  ///
  /// Returns a [String] containing the summary or an error message.
  Future<String> generateContent(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key is not set.');
    }

    final systemInstructions =
        'You are an AI assistant specialized in summarizing news articles. Provide concise, accurate, and neutral summaries without personal opinions.\n\n';

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
