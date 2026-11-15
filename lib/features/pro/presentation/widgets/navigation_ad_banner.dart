import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/pro_controller.dart';
import '../pro_upgrade_modal.dart';
import '../../../../../core/theme/app_colors.dart';

class NavigationAdBanner extends ConsumerStatefulWidget {
  const NavigationAdBanner({super.key});

  @override
  ConsumerState<NavigationAdBanner> createState() => _NavigationAdBannerState();
}

class _NavigationAdBannerState extends ConsumerState<NavigationAdBanner> {
  // Official Google AdMob Android Sample Banner Unit ID for Testing
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final isPro = ref.read(proControllerProvider).isPro;
    if (isPro) return;

    try {
      _bannerAd = BannerAd(
        adUnitId: _testBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
          },
        ),
      )..load();
    } catch (_) {
      // Platform channels not initialized (e.g. desktop/unit tests)
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proState = ref.watch(proControllerProvider);
    if (proState.isPro) {
      _bannerAd?.dispose();
      _bannerAd = null;
      return const SizedBox.shrink();
    }

    final theme = proState.isNightVision ? CompassTheme.nightVision : CompassTheme.normal;

    // If Google AdMob banner is live and loaded, show real AdWidget
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Elegant fallback tactical sponsor card (offline or loading)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.textSecondary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.goldPro.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.goldPro.withOpacity(0.3), width: 0.8),
            ),
            child: Text(
              'AD',
              style: TextStyle(
                color: theme.goldPro,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GARMIN INREACH TACTICAL',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Satellite communicator & SOS tracking',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => ProUpgradeModal.show(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.goldPro,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.black, size: 14),
                  SizedBox(width: 3),
                  Text(
                    'GO PRO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
