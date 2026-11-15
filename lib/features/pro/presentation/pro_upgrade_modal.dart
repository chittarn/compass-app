import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pro_controller.dart';
import '../../../../core/theme/app_colors.dart';

class ProUpgradeModal extends ConsumerWidget {
  const ProUpgradeModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProUpgradeModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proState = ref.watch(proControllerProvider);
    final proNotifier = ref.read(proControllerProvider.notifier);
    final theme = proState.isNightVision ? CompassTheme.nightVision : CompassTheme.normal;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: proState.isPro ? theme.accentCyan : theme.goldPro,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.goldPro.withOpacity(0.3),
                            theme.accentAmber.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: theme.goldPro,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proState.isPro ? 'COMPASS PRO ACTIVE' : 'UPGRADE TO PRO',
                          style: TextStyle(
                            color: proState.isPro ? theme.accentCyan : theme.goldPro,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'TACTICAL NAVIGATION SUITE',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: theme.background, height: 1),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Pro Features Cards
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.block_rounded,
                  iconColor: theme.accentGreen,
                  title: '100% Ad-Free Experience',
                  desc: 'Removes all banners and sponsored equipment slots. Zero tracking, zero latency, maximum screen space.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.my_location_rounded,
                  iconColor: theme.goldPro,
                  title: 'Bearing Lock & Drift Alarms',
                  desc: 'Tap dial to pin target heading. Displays dynamic off-course deviation angle with directional haptic guidance.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.nightlight_round,
                  iconColor: theme.northRed,
                  title: 'Monochrome Red Night Vision',
                  desc: 'Military scotopic vision protection. Deep red spectrum on pitch-black background prevents night blindness.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.pin_drop_rounded,
                  iconColor: theme.accentCyan,
                  title: 'Waypoint Saver (Return to Car/Camp)',
                  desc: 'Pin your coordinates with 1 tap. Compass needle points directly back to your marked point with live range.',
                ),

                const SizedBox(height: 24),

                // Interactive Developer / User Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: proState.isPro
                          ? theme.accentCyan.withOpacity(0.3)
                          : theme.textSecondary.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proState.isPro ? 'Pro Status: UNLOCKED' : 'Pro Status: FREE TIER',
                            style: TextStyle(
                              color: proState.isPro ? theme.accentCyan : theme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            proState.isPro
                                ? 'All 4 Pro navigation features unlocked'
                                : 'Banner ad active • Pro features locked',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: proState.isPro,
                        activeColor: theme.accentCyan,
                        activeTrackColor: theme.accentCyan.withOpacity(0.4),
                        inactiveThumbColor: theme.textSecondary,
                        inactiveTrackColor: theme.surface,
                        onChanged: (val) {
                          proNotifier.setPro(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main Purchase Action Button
                ElevatedButton(
                  onPressed: () {
                    proNotifier.togglePro();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          proState.isPro
                              ? 'Reset back to Free Tier with banner ads.'
                              : '🎉 Welcome to Compass Pro! All features unlocked.',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: proState.isPro ? theme.surfaceElevated : theme.accentGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: proState.isPro ? theme.surfaceElevated : theme.goldPro,
                    foregroundColor: proState.isPro ? theme.textPrimary : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    proState.isPro ? 'TOGGLE TO FREE TIER' : 'UNLOCK PRO (ONE-TIME \$1.99)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: proState.isPro ? theme.textPrimary : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Lifetime License • Family Sharing Supported • No Subscriptions',
                    style: TextStyle(
                      color: theme.textSecondary.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required CompassTheme theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
