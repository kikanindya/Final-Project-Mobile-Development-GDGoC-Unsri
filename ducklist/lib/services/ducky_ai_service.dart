import 'dart:convert';
import 'package:http/http.dart' as http;

class DuckyAIService {
  static const String _apiKey = 'api';

  static Future<String> analyzeTaskHub(String userInput) async {
    if (_apiKey.isEmpty) {
      return "🦆 Kwek! API Key kamu masih kosong.";
    }

    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "meta-llama/llama-4-scout-17b-16e-instruct", // Model aktif yang didukung
          "messages": [
            {
              "role": "system",
              "content": "Kamu adalah Ducky, asisten bebek AI yang cerdas, ramah, dan selalu menggunakan emoji bebek (🦆) di aplikasi produktivitas Ducklist. Jawablah setiap pertanyaan atau tugas pengguna secara natural dalam bahasa Indonesia yang santai."
            },
            {
              "role": "user",
              "content": userInput
            }
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'];
        return text ?? "🦆 Kwek... Ducky sedang bingung, coba lagi ya!";
      } else {
        return "🦆 Gagal dari Server Groq (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "🦆 Gagal terhubung ke server Ducky AI: $e";
    }
  }
}