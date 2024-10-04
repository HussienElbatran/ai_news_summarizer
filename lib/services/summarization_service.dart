import 'dart:convert';
import 'package:http/http.dart' as http;

class SummarizationService {
  final String _apiKey = '7948ca1bd3mshbd6d48a8c2c60e7p10e837jsn3d0805ad4bc3' ; // Replace with your API key
  final String _endpoint = 'https://news-article-data-extract-and-summarization1.p.rapidapi.com/extract/';

  Future<String> summarizeText(String text) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: json.encode({
        'text': text,
        'length': 100, // Adjust as needed
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['summary'].trim();
    } else {
      throw Exception('Failed to summarize text');
    }
  }
}
