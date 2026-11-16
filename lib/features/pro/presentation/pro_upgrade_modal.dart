import 'package:flutter/foundation.dart';
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
    final theme = proState.effectiveTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          'TACTICAL NAVIGATION & VASTU SUITE',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 10.5,
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

          // Body with Pro Feature Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Lifetime Pricing Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.goldPro.withOpacity(0.18),
                        theme.accentAmber.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.goldPro.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIFETIME ACCESS',
                                style: TextStyle(
                                  color: theme.goldPro,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'One-time payment • No subscriptions',
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.goldPro,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '\$1.99',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: theme.goldPro.withOpacity(0.2), height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: theme.goldPro, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pay once, keep forever. Family Library eligible on Google Play.',
                              style: TextStyle(
                                color: theme.textSecondary.withOpacity(0.9),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Text(
                      'AVAILABLE PRO FEATURES',
                      style: TextStyle(
                        color: theme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.accentGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'READY',
                        style: TextStyle(
                          color: theme.accentGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.nightlight_round,
                  iconColor: theme.northRed,
                  title: 'Red OLED Night Vision',
                  desc: 'Military scotopic vision preservation. Pure deep-red spectrum on true black prevents night blindness during stargazing and night operations.',
                  badge: 'AVAILABLE',
                  badgeColor: theme.accentGreen,
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.my_location_rounded,
                  iconColor: theme.goldPro,
                  title: 'Bearing Lock & Drift Navigation',
                  desc: 'Lock any target heading with 1 tap. Dynamic off-course deviation readout with directional haptic guidance.',
                  badge: 'AVAILABLE',
                  badgeColor: theme.accentGreen,
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.pin_drop_rounded,
                  iconColor: theme.accentCyan,
                  title: 'Unlimited Saved Locations & Categories',
                  desc: 'Save and manage unlimited custom waypoints (Home, Work, Travel, Custom with notes). Real-time distance, bearing, and backtrack return needle.',
                  badge: 'AVAILABLE',
                  badgeColor: theme.accentGreen,
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.file_download_outlined,
                  iconColor: theme.accentGreen,
                  title: 'GPX & CSV Waypoint Export',
                  desc: 'Export your saved waypoints directly to standard GPX 1.1 and CSV files for Google Earth, GIS software, and handheld GPS units.',
                  badge: 'AVAILABLE',
                  badgeColor: theme.accentGreen,
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.grid_view_rounded,
                  iconColor: const Color(0xFFFFD700),
                  title: '32-Zone Vastu Purusha Mandala & Commercial Directives',
                  desc: 'Precision Vedic energy mapping across all 32 Devata Padas with doorway entrance ratings and dedicated commercial office guidelines.',
                  badge: 'AVAILABLE',
                  badgeColor: theme.accentGreen,
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.palette_outlined,
                  iconColor: theme.accentCyan,
                  title: 'Tactical UI Themes',
                  desc: 'Custom UI colorways including Tactical Amber, Arctic Cyan, and Ultra-Dark OLED Red Vision.',
                  badge: 'AVAILABLE',
                  badgeColor: theme.accentGreen,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Text(
                      'PLANNED ROADMAP ENHANCEMENTS',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.textSecondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ROADMAP',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.wb_sunny_rounded,
                  iconColor: const Color(0xFFFFD54F),
                  title: 'Advanced Celestial Ephemeris',
                  desc: 'High-precision solar & lunar elevation angles, exact solar noon, golden hour times, and lunar phase illumination.',
                  badge: 'COMING SOON',
                  badgeColor: theme.accentAmber,
                ),
                const SizedBox(height: 10),
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.cloud_sync_outlined,
                  iconColor: theme.accentCyan,
                  title: 'Cloud Waypoint Sync & Multi-Device Backup',
                  desc: 'Optional end-to-end encrypted backup and synchronization of your saved spots across multiple devices.',
                  badge: 'COMING SOON',
                  badgeColor: theme.accentAmber,
                ),

                const SizedBox(height: 20),

                // Main Purchase Action Button
                ElevatedButton(
                  onPressed: () {
                    if (proState.isPro) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🌟 Compass Pro is already active on this device!'),
                          backgroundColor: Color(0xFF161922),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Billing is prepared, but not active yet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🛒 Google Play In-App Purchase is being prepared for the upcoming release!'),
                          backgroundColor: Color(0xFF161922),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: proState.isPro ? theme.accentGreen : theme.goldPro,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        proState.isPro ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        proState.isPro
                            ? 'COMPASS PRO ACTIVE'
                            : 'UPGRADE TO PRO — \$1.99 (COMING SOON)',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Lifetime License • Family Sharing Supported • No Subscriptions',
                    style: TextStyle(
                      color: theme.textSecondary.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ),

                // Development-Only Testing Mechanism (Strictly excluded in Release builds)
                if (kDebugMode) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '[DEV ONLY] Entitlement Simulator',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              proState.isPro ? 'State: Pro Active' : 'State: Free Tier',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.amber.withOpacity(0.2),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            proNotifier.debugTogglePro();
                          },
                          child: Text(
                            proState.isPro ? 'Revoke Pro' : 'Grant Pro',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

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
    String? badge,
    Color? badgeColor,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? theme.accentCyan).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (badgeColor ?? theme.accentCyan).withOpacity(0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor ?? theme.accentCyan,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
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
