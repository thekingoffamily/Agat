import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ads.dart';

const _replies = [
  'Мрр. Сначала поспи, потом геройствуй.',
  'Я бы на твоём месте ничего не решал на голодный желудок.',
  'Если сомневаешься — не надо. Если не сомневаешься — всё равно подумай.',
  'Это не срочно. Просто шумно.',
  'Сделай один маленький шаг. Потом я разрешу лежать.',
  'Люди усложняют. Коты нет.',
  'Ты уже знаешь ответ. Я тут для бантика.',
];

Future<void> main() async {
  await initYandexAds();
  runApp(const AgatApp());
}

class AgatApp extends StatelessWidget {
  const AgatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Агат',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        textTheme: GoogleFonts.karlaTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0A0A0C),
          primary: Color(0xFFD4A017),
          onSurface: Color(0xFFE8EEF2),
        ),
      ),
      home: const AgatHome(),
    );
  }
}

class AgatHome extends StatefulWidget {
  const AgatHome({super.key});

  @override
  State<AgatHome> createState() => _AgatHomeState();
}

class _AgatHomeState extends State<AgatHome> {
  final _ask = TextEditingController();
  String? _answer;
  final _rng = Random();

  @override
  void dispose() {
    _ask.dispose();
    super.dispose();
  }

  void _reply() {
    if (_ask.text.trim().isEmpty) return;
    setState(() => _answer = _replies[_rng.nextInt(_replies.length)]);
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A017);
    const ink = Color(0xFFE8EEF2);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.1,
            colors: [Color(0xFF16161C), Color(0xFF0A0A0C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Агат',
                        style: GoogleFonts.cinzel(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: gold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'спроси — ответит',
                        style: GoogleFonts.karla(
                          fontSize: 16,
                          color: ink.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: Image.asset(
                          'assets/icon.png',
                          width: 220,
                          height: 220,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          _answer ?? 'смотрит. ждёт вопрос.',
                          key: ValueKey(_answer ?? 'idle'),
                          style: GoogleFonts.karla(
                            fontSize: 18,
                            height: 1.4,
                            color: ink,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextField(
                        controller: _ask,
                        style: GoogleFonts.karla(color: ink, fontSize: 18),
                        cursorColor: gold,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _reply(),
                        decoration: InputDecoration(
                          hintText: 'что у тебя',
                          hintStyle: GoogleFonts.karla(
                            color: ink.withValues(alpha: 0.4),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: ink.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: gold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const StickyBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
