import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/waypoints_controller.dart';
import '../domain/waypoint.dart';
import '../../compass/presentation/controllers/compass_controller.dart';
import '../../pro/controllers/pro_controller.dart';
import '../../pro/presentation/pro_upgrade_modal.dart';
import '../../../../core/theme/app_colors.dart';

class WaypointModal extends ConsumerStatefulWidget {
  const WaypointModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WaypointModal(),
    );
  }

  @override
  ConsumerState<WaypointModal> createState() => _WaypointModalState();
}

class _WaypointModalState extends ConsumerState<WaypointModal> {
  final TextEditingController _titleController = TextEditingController(text: 'My Spot');

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wpState = ref.watch(waypointsControllerProvider);
    final wpNotifier = ref.read(waypointsControllerProvider.notifier);
    final compassState = ref.watch(compassControllerProvider);
    final proState = ref.watch(proControllerProvider);

    final bool hasGps = compassState.latitude != null && compassState.longitude != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161922),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dialTickMajor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pin_drop_rounded,
                    color: Color(0xFF00E5FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WAYPOINT NAVIGATION',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mark your spot & follow the cyan dial beacon back',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mark Current Location Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_location_alt_rounded, color: Color(0xFF00E5FF), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'SAVE CURRENT SPOT',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      if (!proState.isPro)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dialTickMajor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '1 FREE SPOT',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Spot Name Input Field
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Parked Car, Trailhead, Camp...',
                      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF12141A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.dialTick.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.dialTick.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // GPS Coordinates Preview
                  Text(
                    hasGps
                        ? 'Fix: ${compassState.formattedCoordinates}'
                        : '⚠️ Waiting for GPS fix before marking...',
                    style: TextStyle(
                      color: hasGps ? AppColors.textSecondary : AppColors.accentAmber,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Save Spot Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: const Color(0xFF0F1115),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                    label: const Text(
                      'MARK THIS SPOT',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                    ),
                    onPressed: !hasGps
                        ? null
                        : () async {
                            final title = _titleController.text.trim();
                            await wpNotifier.saveCurrentSpot(
                              title: title.isEmpty ? 'Marked Spot' : title,
                              latitude: compassState.latitude!,
                              longitude: compassState.longitude!,
                              altitude: compassState.altitude,
                              isPro: proState.isPro,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('📍 Spot "$title" saved! Cyan needle points back.'),
                                  backgroundColor: const Color(0xFF161922),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active / Saved Spots List
            if (wpState.waypoints.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SAVED SPOTS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (wpState.hasActiveWaypoint)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => wpNotifier.setActive(null),
                      child: const Text(
                        'Clear Active Beacon',
                        style: TextStyle(color: AppColors.northRed, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              ...wpState.waypoints.map((wp) {
                final isActive = wp.id == wpState.activeWaypointId;
                String distStr = '--';
                String bearingStr = '';
                if (hasGps) {
                  distStr = wp.formattedDistanceFrom(compassState.latitude!, compassState.longitude!);
                  final b = wp.bearingFrom(compassState.latitude!, compassState.longitude!);
                  bearingStr = '${b.round()}°';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF00E5FF).withOpacity(0.12) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? const Color(0xFF00E5FF) : AppColors.dialTick.withOpacity(0.4),
                      width: isActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: Icon(
                      isActive ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isActive ? const Color(0xFF00E5FF) : AppColors.textSecondary,
                    ),
                    title: Text(
                      wp.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      hasGps ? '$distStr  |  $bearingStr' : 'GPS required for real-time tracking',
                      style: TextStyle(
                        color: isActive ? const Color(0xFF00E5FF) : AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                      onPressed: () => wpNotifier.deleteWaypoint(wp.id),
                    ),
                    onTap: () {
                      if (isActive) {
                        wpNotifier.setActive(null);
                      } else {
                        wpNotifier.setActive(wp.id);
                      }
                    },
                  ),
                );
              }),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No saved spots yet. Tap "Mark This Spot" above.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Pro Multi-Waypoint Upsell if free
            if (!proState.isPro)
              InkWell(
                onTap: () => ProUpgradeModal.show(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldPro.withOpacity(0.15),
                        AppColors.accentAmber.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldPro.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.goldPro, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Pro unlocks unlimited Waypoints & custom coordinates.',
                          style: TextStyle(
                            color: AppColors.goldPro,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.goldPro, size: 14),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
