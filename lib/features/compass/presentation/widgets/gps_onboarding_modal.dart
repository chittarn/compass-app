import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/compass_controller.dart';

class GpsOnboardingModal extends StatelessWidget {
  final WidgetRef ref;

  const GpsOnboardingModal({super.key, required this.ref});

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GpsOnboardingModal(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentCyan.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.accentCyan.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tactical Drag Pill
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dialTick,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Header Icon & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentCyan.withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.satellite_alt_rounded,
                  color: AppColors.accentCyan,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SATELLITE TELEMETRY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Enable GPS for live celestial & nav features',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Feature Highlights Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dialRing),
            ),
            child: Column(
              children: [
                _buildFeatureRow(
                  icon: Icons.location_on_rounded,
                  color: AppColors.accentCyan,
                  title: 'Live Coordinates & MSL Altitude',
                  subtitle: 'Real-time GPS position on top HUD',
                ),
                const Divider(color: AppColors.dialRing, height: 16),
                _buildFeatureRow(
                  icon: Icons.wb_sunny_rounded,
                  color: AppColors.accentAmber,
                  title: 'Sun & Moon Azimuth on Dial Rim',
                  subtitle: 'Live solar dawn, dusk & celestial tracking',
                ),
                const Divider(color: AppColors.dialRing, height: 16),
                _buildFeatureRow(
                  icon: Icons.explore_rounded,
                  color: const Color(0xFF00E676),
                  title: 'True North & Qibla Direction',
                  subtitle: 'Automatic magnetic declination correction',
                ),
                const Divider(color: AppColors.dialRing, height: 16),
                _buildFeatureRow(
                  icon: Icons.pin_drop_rounded,
                  color: AppColors.accentCyan,
                  title: 'Waypoint Backtrack Navigation',
                  subtitle: 'Cyan beacon needle to guide you back to your spot',
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary Activate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                foregroundColor: AppColors.background,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.my_location_rounded, size: 20),
              label: const Text(
                'ACTIVATE SATELLITE GPS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(compassControllerProvider.notifier)
                    .requestGpsPermissionAndFix();
              },
            ),
          ),

          const SizedBox(height: 10),

          // Secondary Offline Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CONTINUE WITH OFFLINE SENSORS ONLY',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
