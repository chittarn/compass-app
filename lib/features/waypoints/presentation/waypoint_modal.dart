import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/waypoints_controller.dart';
import '../domain/waypoint.dart';
import '../../compass/presentation/controllers/compass_controller.dart';
import '../../pro/controllers/pro_controller.dart';
import '../../pro/presentation/pro_upgrade_modal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/waypoint_exporter.dart';

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
  final TextEditingController _titleController = TextEditingController(
    text: 'My Spot',
  );
  final TextEditingController _notesController = TextEditingController();
  WaypointCategory _selectedCategory = WaypointCategory.custom;
  bool _isAcquiring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _acquireGps();
    });
  }

  Future<void> _acquireGps() async {
    final compassState = ref.read(compassControllerProvider);
    if (compassState.latitude != null && compassState.longitude != null) return;
    setState(() => _isAcquiring = true);
    await ref
        .read(compassControllerProvider.notifier)
        .requestGpsPermissionAndFix();
    if (mounted) {
      setState(() => _isAcquiring = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wpState = ref.watch(waypointsControllerProvider);
    final wpNotifier = ref.read(waypointsControllerProvider.notifier);
    final compassState = ref.watch(compassControllerProvider);
    final proState = ref.watch(proControllerProvider);
    final theme = proState.effectiveTheme;

    final bool hasGps =
        compassState.latitude != null && compassState.longitude != null;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dialTickMajor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

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
                    size: 22,
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Mark spots with notes & follow the cyan beacon back',
                        style: TextStyle(
                          color: theme.textSecondary.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.close_rounded, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mark Current Location Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.add_location_alt_rounded,
                        color: Color(0xFF00E5FF),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'SAVE CURRENT SPOT',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: proState.isPro
                              ? theme.accentCyan.withOpacity(0.15)
                              : theme.dialTickMajor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          proState.isPro ? 'UNLIMITED' : '5 FREE SPOTS',
                          style: TextStyle(
                            color: proState.isPro
                                ? theme.accentCyan
                                : theme.textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category Selector Chips
                  Row(
                    children: WaypointCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00E5FF).withOpacity(0.2)
                                    : theme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00E5FF)
                                      : theme.dialRing,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat.emoji,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    cat.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF00E5FF)
                                          : theme.textSecondary,
                                      fontSize: 10.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  // Spot Name Input Field
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: theme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Spot Name (e.g. Parked Car, Campsite)...',
                      hintStyle: TextStyle(
                        color: theme.textSecondary.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: theme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dialRing),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dialRing),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Optional Notes Field
                  TextField(
                    controller: _notesController,
                    style: TextStyle(color: theme.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Notes (optional, e.g. Level 2 Slot 45, trail marker)...',
                      hintStyle: TextStyle(
                        color: theme.textSecondary.withOpacity(0.5),
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: theme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dialRing),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dialRing),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // GPS Coordinates Preview
                  Text(
                    hasGps
                        ? 'Fix: ${compassState.formattedCoordinates} • ${compassState.formattedAltitude}'
                        : (_isAcquiring
                              ? '📡 Contacting GPS satellites for coordinates...'
                              : '⚠️ Waiting for GPS fix before marking...'),
                    style: TextStyle(
                      color: hasGps ? theme.textSecondary : theme.accentAmber,
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                    ),
                  ),

                  if (!hasGps) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00E5FF),
                        side: const BorderSide(color: Color(0xFF00E5FF)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isAcquiring
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF00E5FF),
                              ),
                            )
                          : const Icon(Icons.my_location_rounded, size: 16),
                      label: Text(
                        _isAcquiring
                            ? 'ACQUIRING FIX...'
                            : 'ENABLE LOCATION / GET FIX',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _isAcquiring ? null : _acquireGps,
                    ),
                  ],

                  const SizedBox(height: 10),

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
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: !hasGps
                        ? null
                        : () async {
                            if (!proState.isPro &&
                                wpState.waypoints.length >=
                                    WaypointsController.freeWaypointLimit) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: theme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.workspace_premium_rounded,
                                        color: AppColors.goldPro,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Waypoint Limit Reached',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'Free tier includes up to 5 saved spots. Upgrade to Pro for unlimited waypoints, or delete an existing spot to save a new one.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        'CANCEL',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.goldPro,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        ProUpgradeModal.show(context);
                                      },
                                      child: const Text(
                                        'UPGRADE TO PRO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            final title = _titleController.text.trim();
                            final spotTitle = title.isEmpty
                                ? 'Marked Spot'
                                : title;
                            final saved = await wpNotifier.saveCurrentSpot(
                              title: spotTitle,
                              latitude: compassState.latitude!,
                              longitude: compassState.longitude!,
                              altitude: compassState.altitude,
                              category: _selectedCategory,
                              notes: _notesController.text.trim(),
                              isPro: proState.isPro,
                            );
                            if (context.mounted && saved != null) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '📍 Spot "$spotTitle" saved! Cyan needle points back.',
                                  ),
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
            const SizedBox(height: 16),

            // Active / Saved Spots List
            if (wpState.waypoints.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SAVED SPOTS (${wpState.waypoints.length}${proState.isPro ? ' • UNLIMITED' : '/5'})',
                    style: TextStyle(
                      color: theme.textSecondary,
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
                        style: TextStyle(
                          color: AppColors.northRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              ...wpState.waypoints.map((wp) {
                final isActive = wp.id == wpState.activeWaypointId;
                String distStr = '--';
                String bearingStr = '';
                bool isArrived = false;
                if (hasGps) {
                  distStr = wp.formattedDistanceFrom(
                    compassState.latitude!,
                    compassState.longitude!,
                  );
                  final b = wp.bearingFrom(
                    compassState.latitude!,
                    compassState.longitude!,
                  );
                  bearingStr = '${b.round()}°';
                  isArrived = wp.isArrived(
                    compassState.latitude!,
                    compassState.longitude!,
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF00E5FF).withOpacity(0.12)
                        : theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF00E5FF)
                          : theme.dialRing,
                      width: isActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00E5FF).withOpacity(0.2)
                            : theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        wp.category.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            wp.title,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isArrived) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ARRIVED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasGps
                              ? '$distStr  |  $bearingStr'
                              : 'GPS required for real-time tracking',
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF00E5FF)
                                : theme.textSecondary,
                            fontSize: 11.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (wp.notes != null && wp.notes!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            wp.notes!,
                            style: TextStyle(
                              color: theme.textSecondary.withOpacity(0.85),
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.textSecondary,
                        size: 20,
                      ),
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
                      color: theme.textSecondary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // GPX / CSV Export Feature (PRO)
            InkWell(
              onTap: () {
                if (proState.isPro) {
                  _showExportModal(context, wpState.waypoints, theme);
                } else {
                  ProUpgradeModal.show(context);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldPro.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.file_download_outlined,
                      color: AppColors.goldPro,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Export Waypoints (GPX & CSV)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            proState.isPro
                                ? 'Export to Google Earth, GPS handhelds & GIS'
                                : 'Pro feature: Export waypoints in GPX 1.1 & CSV',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldPro.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        proState.isPro ? 'EXPORT' : 'PRO',
                        style: const TextStyle(
                          color: AppColors.goldPro,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

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
                    border: Border.all(
                      color: AppColors.goldPro.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.goldPro,
                        size: 20,
                      ),
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
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.goldPro,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExportModal(
    BuildContext context,
    List<Waypoint> waypoints,
    CompassTheme theme,
  ) {
    if (waypoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No waypoints saved yet to export. Mark a spot first!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  color: AppColors.goldPro,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'EXPORT ${waypoints.length} WAYPOINTS',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Share GPX via System Share Sheet
            ListTile(
              tileColor: theme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(
                Icons.share_rounded,
                color: Color(0xFF00E5FF),
              ),
              title: const Text(
                'Share GPX 1.1 via Apps',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Send to GPS apps, Google Earth, Drive or WhatsApp',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final gpxContent = WaypointExporter.toGpx(waypoints);
                Share.share(
                  gpxContent,
                  subject:
                      'Compass_Waypoints_${DateTime.now().millisecondsSinceEpoch}.gpx',
                );
              },
            ),
            const SizedBox(height: 8),

            // Share CSV via System Share Sheet
            ListTile(
              tileColor: theme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(
                Icons.table_chart_rounded,
                color: Color(0xFF00E676),
              ),
              title: const Text(
                'Share CSV Spreadsheet via Apps',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Standard CSV table for Excel, Sheets & GIS tools',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final csvContent = WaypointExporter.toCsv(waypoints);
                Share.share(
                  csvContent,
                  subject:
                      'Compass_Waypoints_${DateTime.now().millisecondsSinceEpoch}.csv',
                );
              },
            ),
            const SizedBox(height: 8),

            // Copy GPX to Clipboard
            ListTile(
              tileColor: theme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.copy_rounded, color: AppColors.goldPro),
              title: const Text(
                'Copy GPX (XML) to Clipboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Instant paste into text editors or GIS software',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final gpx = WaypointExporter.toGpx(waypoints);
                Clipboard.setData(ClipboardData(text: gpx));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📋 GPX 1.1 XML copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Copy CSV to Clipboard
            ListTile(
              tileColor: theme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(
                Icons.copy_all_rounded,
                color: AppColors.goldPro,
              ),
              title: const Text(
                'Copy CSV to Clipboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Instant paste into spreadsheets or notes',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final csv = WaypointExporter.toCsv(waypoints);
                Clipboard.setData(ClipboardData(text: csv));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📋 CSV data copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
