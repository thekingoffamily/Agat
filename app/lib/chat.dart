import 'dart:convert';

import 'package:http/http.dart' as http;

const agatApi = String.fromEnvironment(
  'AGAT_API',
  defaultValue: 'http://31.172.72.212:28471',
);

Future<String> askAgat(String text, List<({bool me, String text})> history) async {
  final start = history.length > 8 ? history.length - 8 : 0;
  final hist = [
    for (final m in history.sublist(start))
      {'role': m.me ? 'user' : 'assistant', 'content': m.text},
  ];
  final r = await http
      .post(
        Uri.parse('$agatApi/api/public/agat/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'history': hist}),
      )
      .timeout(const Duration(seconds: 100));
  if (r.statusCode == 429) return 'Много сразу. Подожди немного.';
  if (r.statusCode >= 400) {
    throw Exception('agat ${r.statusCode}');
  }
  final data = jsonDecode(r.body);
  final out = (data['text'] as String?)?.trim() ?? '';
  if (out.isEmpty) throw Exception('empty');
  return out;
}
