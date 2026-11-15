import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/vastu_calculator.dart';
import '../controllers/compass_controller.dart';

class VastuGuideModal extends ConsumerStatefulWidget {
  const VastuGuideModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const VastuGuideModal(),
    );
  }

  @override
  ConsumerState<VastuGuideModal> createState() => _VastuGuideModalState();
}

class _VastuGuideModalState extends ConsumerState<VastuGuideModal> {
  VastuRoomType? _selectedRoom;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compassControllerProvider);
    final controller = ref.read(compassControllerProvider.notifier);
    final currentZone = state.currentVastuZone;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dialTick,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                ),
                child: const Text(
                  '🕉️',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'VASTU SHASTRA ARCHITECTURE',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Classical Vedic Directional Harmony & Room Alignment',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Live Current Zone Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(currentZone.colorValue).withOpacity(0.18),
                  AppColors.background,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(currentZone.colorValue).withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentZone.sanskritName,
                          style: TextStyle(
                            color: Color(currentZone.colorValue),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(currentZone.colorValue).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentZone.direction,
                            style: TextStyle(
                              color: Color(currentZone.colorValue),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currentZone.elementLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ruled by ${currentZone.rulingDeity} • Arc: ${currentZone.startDegrees}° – ${currentZone.endDegrees}°',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Divider(color: AppColors.dialRing, height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Best for: ${currentZone.bestFor.join(", ")}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_rounded, color: AppColors.northRed, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Avoid: ${currentZone.avoid.join(", ")}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'SELECT A ROOM TO TARGET WITH COMPASS NEEDLE:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable Room Guidelines
          Expanded(
            child: ListView.separated(
              itemCount: VastuCalculator.roomGuidelines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final guide = VastuCalculator.roomGuidelines[index];
                final isSelected = _selectedRoom == guide.type || state.activeVastuRoom == guide.type;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRoom = guide.type;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD700).withOpacity(0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFD700) : AppColors.dialRing,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              guide.title,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFFFD700) : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                              ),
                              child: Text(
                                '${guide.idealDirection} (${guide.targetHeading.round()}°)',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          guide.description,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '💡 Reason: ${guide.reason}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.navigation_rounded, size: 16),
                              label: Text(
                                state.activeVastuRoom == guide.type
                                    ? 'LOCK ENGAGED • TAP TO DISMISS'
                                    : 'POINT COMPASS NEEDLE TO THIS ZONE',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              onPressed: () {
                                if (state.activeVastuRoom == guide.type) {
                                  controller.setActiveVastuRoom(null);
                                } else {
                                  controller.setActiveVastuRoom(guide.type);
                                  if (!state.isVastuMode) {
                                    controller.toggleVastuMode();
                                  }
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
