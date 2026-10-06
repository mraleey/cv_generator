import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cv_model.dart';
import '../controllers/cv_controller.dart';

class GrokService {
  final String apiKey;

  GrokService(this.apiKey);

  Future<String> enhanceSummary(String draft) async {
    if (apiKey.isEmpty) {
      throw Exception('API key is missing.');
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt =
        '''
You are an expert executive resume builder and technical career coach.

Your task:
Take the user's draft profile summary and enhance it into a polished, high-impact, ATS-optimized executive bio (2-3 sentences).
Make it professional, action-oriented, and eliminate first-person pronouns ("I", "my", "we").

User's Draft Summary:
$draft

Output ONLY the enhanced summary text. Do not include any introductory or concluding commentary.
''';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'openai/gpt-oss-20b',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to connect to Groq API: \${response.body}');
    }

    final data = jsonDecode(response.body);
    final text = data['choices']?[0]?['message']?['content'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Received empty response from Groq.');
    }

    return text.trim();
  }

  Future<TemplateStyle> suggestTemplate(CVModel cv) async {
    if (apiKey.isEmpty) {
      return TemplateStyle.classic;
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt =
        '''
You are an ATS resume expert. Based on the user's profile summary and tech stack, select the best resume template.
Available templates: classic, modern, minimalist, executive.

Rules:
- If they are a C-level or manager (e.g. Director, VP, CEO), choose "executive".
- If they are a creative or front-end developer, choose "modern".
- If they have heavy backend/data/sysadmin experience, choose "minimalist" (ATS friendly).
- Otherwise, choose "classic".

User Summary: ${cv.profileSummary}
Tech Stack: ${cv.skillsCategorized.technical.join(', ')}

Output ONLY the exact word of the template. No punctuation.
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-20b',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        final cleaned = text?.trim().toLowerCase() ?? '';

        if (cleaned.contains('executive')) return TemplateStyle.executive;
        if (cleaned.contains('modern')) return TemplateStyle.modern;
        if (cleaned.contains('minimalist')) return TemplateStyle.minimalist;
      }
    } catch (e) {
      // Fallback
    }

    return TemplateStyle.classic;
  }

  Future<String> suggestJobBullets(
    String jobTitle,
    String company,
    String techSkills,
    String tools,
    String softSkills,
  ) async {
    if (apiKey.isEmpty) throw Exception('API key is missing.');

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt =
        '''
You are an expert resume writer. The user is writing their resume for the role of "$jobTitle" at "$company".
They have the following skills: 
- Tech: $techSkills
- Tools: $tools
- Soft Skills: $softSkills

Provide 5 powerful, highly detailed, and lengthy ATS-friendly bullet points using the Google XYZ formula (Accomplished X as measured by Y, by doing Z). 
The bullets must intelligently incorporate the skills listed above to demonstrate expertise, and they should be comprehensive enough to substantially fill out the resume page.
Do not include any introductory or concluding text. Do not number them, just put each on a new line.
Make them sound professional, impactful, and extensive.
''';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'openai/gpt-oss-20b',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to connect to Groq API');
    }

    final data = jsonDecode(response.body);
    return (data['choices']?[0]?['message']?['content'] as String?)?.trim() ??
        '';
  }

  Future<String> suggestSkills(String summary) async {
    if (apiKey.isEmpty) throw Exception('API key is missing.');

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt =
        '''
You are an expert ATS parser. Read the user's profile summary below and extract/infer 5 to 7 relevant technical and soft skills.
Output ONLY the skills separated by commas, nothing else.

Summary:
$summary
''';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'openai/gpt-oss-20b',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to connect to Groq API');
    }

    final data = jsonDecode(response.body);
    return (data['choices']?[0]?['message']?['content'] as String?)?.trim() ??
        '';
  }
}
