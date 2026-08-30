import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ads.dart';
import 'chat.dart';

const _gold = Color(0xFFD4A017);
const _ink = Color(0xFFE8EEF2);
const _navy = Color(0xFF1E3A5F);

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
          primary: _gold,
          onSurface: _ink,
        ),
      ),
      home: const AgatHome(),
    );
  }
}

class _Msg {
  const _Msg({required this.me, required this.text});
  final bool me;
  final String text;
}

class AgatHome extends StatefulWidget {
  const AgatHome({super.key});

  @override
  State<AgatHome> createState() => _AgatHomeState();
}

class _AgatHomeState extends State<AgatHome> with TickerProviderStateMixin {
  final _ask = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[
    const _Msg(me: false, text: 'смотрит. ждёт вопрос.'),
  ];
  var _busy = false;
  late final AnimationController _bob;
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _dots = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ask.dispose();
    _scroll.dispose();
    _bob.dispose();
    _dots.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _ask.text.trim();
    if (q.isEmpty || _busy) return;
    _ask.clear();
    setState(() {
      _msgs.add(_Msg(me: true, text: q));
      _busy = true;
    });
    _jump();
    try {
      final hist = _msgs.where((m) => m != _msgs.last).toList();
      final a = await askAgat(q, hist.map((m) => (me: m.me, text: m.text)).toList());
      if (!mounted) return;
      setState(() => _msgs.add(_Msg(me: false, text: a)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _msgs.add(const _Msg(me: false, text: 'Мрр. Связь оборвалась. Ещё раз.'));
      });
    } finally {
      if (mounted) setState(() => _busy = false);
      _jump();
    }
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [Color(0xFF16161C), Color(0xFF0A0A0C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Агат',
                            style: GoogleFonts.cinzel(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: _gold,
                              height: 1,
                            ),
                          ),
                          Text(
                            'кот. отвечает.',
                            style: GoogleFonts.karla(
                              fontSize: 14,
                              color: _ink.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _bob,
                      builder: (_, child) {
                        final t = _bob.value;
                        return Transform.translate(
                          offset: Offset(0, (t - 0.5) * 10),
                          child: Transform.scale(
                            scale: 1 + (_busy ? 0.04 : 0.02) * t,
                            child: child,
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: _busy ? 0.45 : 0.18),
                              blurRadius: _busy ? 28 : 12,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icon.png',
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  itemCount: _msgs.length + (_busy ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_busy && i == _msgs.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _Typing(ctrl: _dots),
                        ),
                      );
                    }
                    final m = _msgs[i];
                    return Align(
                      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          key: ValueKey('${m.me}${m.text}'),
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: m.me ? _navy.withValues(alpha: 0.55) : _ink.withValues(alpha: 0.07),
                            border: Border.all(
                              color: m.me ? _navy : _gold.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            m.text,
                            style: GoogleFonts.karla(fontSize: 16, height: 1.35, color: _ink),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  controller: _ask,
                  enabled: !_busy,
                  style: GoogleFonts.karla(color: _ink, fontSize: 18),
                  cursorColor: _gold,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'что у тебя',
                    hintStyle: GoogleFonts.karla(color: _ink.withValues(alpha: 0.4)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _ink.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: _gold),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'github.com/thekingoffamily/Agat',
                  style: GoogleFonts.karla(
                    fontSize: 10,
                    color: _ink.withValues(alpha: 0.35),
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

class _Typing extends StatelessWidget {
  const _Typing({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Opacity(
                  opacity: ((ctrl.value + i / 3) % 1).clamp(0.25, 1),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
