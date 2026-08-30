import 'package:flutter/material.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

const bannerAdUnitId = String.fromEnvironment(
  'YANDEX_BANNER',
  defaultValue: 'demo-banner-yandex',
);

Future<void> initYandexAds() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YandexAds.initialize();
}

bool get _inWidgetTest =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

class StickyBanner extends StatefulWidget {
  const StickyBanner({super.key});

  @override
  State<StickyBanner> createState() => _StickyBannerState();
}

class _StickyBannerState extends State<StickyBanner> {
  BannerAd? _banner;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || _inWidgetTest) return;
    _started = true;
    final w = MediaQuery.sizeOf(context).width.toInt();
    final banner = BannerAd(adSize: BannerAdSize.sticky(width: w));
    banner.load(const AdRequest(adUnitId: bannerAdUnitId));
    setState(() => _banner = banner);
  }

  @override
  void dispose() {
    _banner?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_inWidgetTest || _banner == null) return const SizedBox.shrink();
    return AdWidget(bannerAd: _banner!);
  }
}
