import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/pro_controller.dart';
import '../pro_upgrade_modal.dart';
import '../../../../../core/theme/app_colors.dart';

class NavigationAdBanner extends ConsumerWidget {
  const NavigationAdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proState = ref.watch(proControllerProvider);
    if (proState.isPro) {
      return const SizedBox.shrink();
    }

    final theme = proState.isNightVision ? CompassTheme.nightVision : CompassTheme.normal;

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
          // Ad Badge
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

          // Ad Copy
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

          // Remove Ads / Go Pro Pill
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
