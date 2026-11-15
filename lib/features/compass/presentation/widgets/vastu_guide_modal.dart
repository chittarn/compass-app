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
  VastuRoomType? _selectedRoom = VastuRoomType.poojaRoom;

  @override
  void initState() {
    super.initState();
    final active = ref.read(compassControllerProvider).activeVastuRoom;
    if (active != null) {
      _selectedRoom = active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compassControllerProvider);
    final controller = ref.read(compassControllerProvider.notifier);
    final currentZone = state.currentVastuZone;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dialTick,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Header Row (Zero-Overflow Guaranteed)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                ),
                child: const Text('🕉️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VASTU HOUSE GUIDE',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Stand in house center. Point phone to check room alignment.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Live Heading Bar: What user is pointing at right now
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(currentZone.colorValue).withOpacity(0.20),
                  AppColors.background,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(currentZone.colorValue).withOpacity(0.55)),
            ),
            child: Row(
              children: [
                Text(currentZone.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'AIMING AT: ${currentZone.direction} (${state.heading.round().toString().padLeft(3, '0')}°)',
                              style: TextStyle(
                                color: Color(currentZone.colorValue),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Color(currentZone.colorValue).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentZone.sanskritName.split('(').first.trim().toUpperCase(),
                              style: TextStyle(
                                color: Color(currentZone.colorValue),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ideal Placement: ${currentZone.plainLabel} • ${currentZone.elementLabel}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3x3 VASTU HOUSE FLOOR PLAN MATRIX
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '3×3 HOUSE FLOOR PLAN MATRIX:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'North is UP ↑',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Visual 3x3 Grid
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dialRing),
            ),
            child: Column(
              children: [
                _buildGridRow([
                  VastuCalculator.houseGrid[0], // NW
                  VastuCalculator.houseGrid[1], // N
                  VastuCalculator.houseGrid[2], // NE
                ], currentZone.direction),
                const SizedBox(height: 5),
                _buildGridRow([
                  VastuCalculator.houseGrid[3], // W
                  VastuCalculator.houseGrid[4], // CENTER
                  VastuCalculator.houseGrid[5], // E
                ], currentZone.direction),
                const SizedBox(height: 5),
                _buildGridRow([
                  VastuCalculator.houseGrid[6], // SW
                  VastuCalculator.houseGrid[7], // S
                  VastuCalculator.houseGrid[8], // SE
                ], currentZone.direction),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Scrollable Room Guidelines Detail Cards
          const Text(
            'SELECT A ROOM TO TARGET WITH COMPASS NEEDLE:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),

          // Room List (Zero-Overflow Guaranteed with Wrap and Flex)
          Expanded(
            child: ListView.separated(
              itemCount: VastuCalculator.roomGuidelines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                        // Room Title & Direction Tag in Wrap to never overflow
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(guide.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  guide.title,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFFFFD700) : AppColors.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withOpacity(0.16),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                              ),
                              child: Text(
                                guide.idealDirection,
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 10,
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
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // DOs and DON'Ts summary
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('✅ ', style: TextStyle(fontSize: 11)),
                                  Expanded(
                                    child: Text(
                                      guide.dos.first,
                                      style: const TextStyle(
                                        color: Color(0xFF00E676),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('❌ ', style: TextStyle(fontSize: 11)),
                                  Expanded(
                                    child: Text(
                                      guide.donts.first,
                                      style: const TextStyle(
                                        color: AppColors.northRed,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (isSelected) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.navigation_rounded, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  state.activeVastuRoom == guide.type
                                      ? 'LOCK ENGAGED • TAP TO DISMISS'
                                      : 'AIM NEEDLE TO ${guide.idealDirection.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
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

  Widget _buildGridRow(List<VastuGridCell> cells, String currentDirection) {
    return Row(
      children: cells.map((cell) {
        final isCurrentPointing = cell.directionCode == currentDirection;
        final isCenter = cell.directionCode == 'CENTER';

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (cell.roomType != null) {
                setState(() {
                  _selectedRoom = cell.roomType;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isCurrentPointing
                    ? const Color(0xFFFFD700).withOpacity(0.25)
                    : (isCenter
                        ? const Color(0xFFFFD700).withOpacity(0.08)
                        : Color(cell.colorValue).withOpacity(0.10)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrentPointing
                      ? const Color(0xFFFFD700)
                      : (isCenter
                          ? const Color(0xFFFFD700).withOpacity(0.35)
                          : Color(cell.colorValue).withOpacity(0.3)),
                  width: isCurrentPointing ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${cell.emoji} ${cell.label}',
                      style: TextStyle(
                        color: isCurrentPointing
                            ? const Color(0xFFFFD700)
                            : (isCenter ? const Color(0xFFFFD700) : Color(cell.colorValue)),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      cell.roomName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isCurrentPointing) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AIM ➔',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ] else if (isCenter) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 0.5),
                      ),
                      child: const Text(
                        'STAND HERE',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 6.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
