import 'dart:convert';
import 'dart:io'; // For accessing environment variables
import 'package:http/http.dart' as http;

class SummarizationService {
  // It's recommended to fetch the API key from environment variables
  final String _apiKey = Platform.environment['AIzaSyDL2nQUWL5jQgp9Kwo2oHtHmm-fV7574oM'] ?? '';

  // Replace with the actual Gemini API endpoint
  final String _endpoint = 'https://generativeai.googleapis.com/v1/models/gemini-1.5-flash-8b:generate';

  Future<String> summarizeText(String text) async {
    // Validate API Key
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key is not set.');
    }

    // Construct the prompt for summarization
    final String prompt = 'Please provide a concise summary for the following text:\n\n$text';

    // Define the request body
    final Map<String, dynamic> requestBody = {
      'prompt': prompt,
      'temperature': 0.7, // Adjust for creativity
      'top_p': 0.9,
      'top_k': 50,
      'max_output_tokens': 4000, // Adjust based on desired summary length
      'response_mime_type': 'text/plain',
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Adjust based on Gemini's actual response structure
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['text'].trim();
        } else {
          throw Exception('No summary found in the response.');
        }
      } else {
        // Handle different status codes and error messages
        throw Exception('Failed to summarize text: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle exceptions such as network errors
      throw Exception('Error during summarization: $e');
    }
  }
}
