import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/vastu_calculator.dart';
import '../controllers/compass_controller.dart';
import '../../../pro/controllers/pro_controller.dart';
import '../../../pro/presentation/pro_upgrade_modal.dart';

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
  VastuGridMode _activeMode = VastuGridMode.eightZone;
  VastuProfileType _activeProfile = VastuProfileType.residential;
  VastuRoomType? _selectedRoom = VastuRoomType.poojaRoom;
  bool _isUsageGuideExpanded = false;

  Widget _buildGuideStep(String stepNumber, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 10, height: 1.3),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final proState = ref.watch(proControllerProvider);
    final controller = ref.read(compassControllerProvider.notifier);
    final theme = proState.effectiveTheme;

    final current8Zone = state.currentVastuZone;
    final current16Zone = VastuCalculator.get16Zone(state.heading);
    final current32Zone = VastuCalculator.get32Zone(state.heading);

    return SafeArea(
      bottom: true,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            width: 1.5,
          ),
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
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: theme.dialTickMajor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '🕉️',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VASTU SHASTRA ARCHITECT',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              _activeProfile == VastuProfileType.residential
                                  ? 'Residential Space Planning & Room Directives'
                                  : 'Commercial & Business Wealth Directives',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 10.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Traditional Guidance Notice Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFFFD700),
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Traditional Indian architectural guidelines for natural light, ventilation & energetic balance.',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quick 5-Step Vastu Workflow Guide (Collapsible)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.25),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => setState(
                      () => _isUsageGuideExpanded = !_isUsageGuideExpanded,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFFFD700),
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'QUICK START: 5-STEP VASTU WORKFLOW',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isUsageGuideExpanded ? 'HIDE' : 'VIEW',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              _isUsageGuideExpanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: const Color(0xFFFFD700),
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isUsageGuideExpanded) ...[
                    const SizedBox(height: 8),
                    _buildGuideStep(
                      '1',
                      'Select Property Type',
                      'Choose Home (Residential) or Office/Shop (Commercial PRO) at the top.',
                    ),
                    _buildGuideStep(
                      '2',
                      'Choose Direction System',
                      'Select 8 Directions (Basic), 16 Energy Zones, or 32 Devata Padas (Doors, PRO).',
                    ),
                    _buildGuideStep(
                      '3',
                      'Reference Matrix',
                      'Use the 3×3 matrix to visualize room positions around the central Brahmasthan (North is UP ↑).',
                    ),
                    _buildGuideStep(
                      '4',
                      'Check Room Placement',
                      'Review recommended cardinal directions, degree bearings, and elemental attributes below.',
                    ),
                    _buildGuideStep(
                      '5',
                      'Aim Needle',
                      'Tap "AIM NEEDLE" on any room to lock a target beacon on the main compass dial. Align the needle to steer.',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Selector Row 1: Profile Switcher (Residential vs Commercial)
            Row(
              children: [
                _buildPillButton(
                  title: '🏡 Home (Residential)',
                  isSelected: _activeProfile == VastuProfileType.residential,
                  onTap: () {
                    setState(() {
                      _activeProfile = VastuProfileType.residential;
                    });
                  },
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildPillButton(
                  title: '🏢 Office / Shop',
                  isProBadge: true,
                  isUnlocked: proState.isPro,
                  isSelected: _activeProfile == VastuProfileType.commercial,
                  onTap: () {
                    if (proState.isPro) {
                      setState(() {
                        _activeProfile = VastuProfileType.commercial;
                      });
                    } else {
                      ProUpgradeModal.show(context);
                    }
                  },
                  theme: theme,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Selector Row 2: Grid Precision Mode (8 Directions, 16 Zones, 32 Padas)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildModeTab(
                    label: '8 Directions',
                    sublabel: 'Basic (Free)',
                    isFree: true,
                    isSelected: _activeMode == VastuGridMode.eightZone,
                    onTap: () =>
                        setState(() => _activeMode = VastuGridMode.eightZone),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildModeTab(
                    label: '16 Energy Zones',
                    sublabel: 'Shodasha (Free)',
                    isFree: true,
                    isSelected: _activeMode == VastuGridMode.sixteenZone,
                    onTap: () =>
                        setState(() => _activeMode = VastuGridMode.sixteenZone),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildModeTab(
                    label: '32 Devata Padas (Doors)',
                    sublabel: 'Door Placement',
                    isFree: false,
                    isUnlocked: proState.isPro,
                    isSelected: _activeMode == VastuGridMode.thirtyTwoZone,
                    onTap: () {
                      if (proState.isPro) {
                        setState(
                          () => _activeMode = VastuGridMode.thirtyTwoZone,
                        );
                      } else {
                        ProUpgradeModal.show(context);
                      }
                    },
                    theme: theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Live Aiming Ribbon (Changes dynamically based on precision mode)
            _buildLiveAimingBar(
              mode: _activeMode,
              heading: state.heading,
              current8Zone: current8Zone,
              current16Zone: current16Zone,
              current32Zone: current32Zone,
              theme: theme,
            ),

            const SizedBox(height: 10),

            // Content Area
            Expanded(
              child: _buildModeContent(
                mode: _activeMode,
                profile: _activeProfile,
                state: state,
                controller: controller,
                proState: proState,
                current8Zone: current8Zone,
                current16Zone: current16Zone,
                current32Zone: current32Zone,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required CompassTheme theme,
    bool isProBadge = false,
    bool isUnlocked = true,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFD700).withOpacity(0.18)
                : theme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD700) : theme.dialRing,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : theme.textPrimary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (isProBadge && !isUnlocked) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    String? sublabel,
    required bool isFree,
    required bool isSelected,
    required VoidCallback onTap,
    required CompassTheme theme,
    bool isUnlocked = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : theme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : theme.dialRing,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : theme.textPrimary,
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (!isFree) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    size: 10,
                    color: isSelected ? Colors.black : const Color(0xFFFFD700),
                  ),
                ],
              ],
            ),
            if (sublabel != null)
              Text(
                sublabel,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : theme.textSecondary,
                  fontSize: 8.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAimingBar({
    required VastuGridMode mode,
    required double heading,
    required VastuZoneInfo current8Zone,
    required Vastu16ZoneInfo current16Zone,
    required Vastu32ZoneInfo current32Zone,
    required CompassTheme theme,
  }) {
    String title;
    String subtitle;
    int colorVal;

    switch (mode) {
      case VastuGridMode.sixteenZone:
        title =
            'CURRENT PHONE DIRECTION: ${current16Zone.code} (${heading.round()}°) — ${current16Zone.name.toUpperCase()}';
        subtitle =
            '${current16Zone.attribute} • Element: ${current16Zone.element.name.toUpperCase()}';
        colorVal = current16Zone.colorValue;
        break;
      case VastuGridMode.thirtyTwoZone:
        title =
            'CURRENT PHONE DIRECTION: ${current32Zone.padaCode} (${current32Zone.deityName}) — ${current32Zone.suitability.label}';
        subtitle = current32Zone.traditionalEffect;
        colorVal = current32Zone.suitability.colorValue;
        break;
      case VastuGridMode.eightZone:
      default:
        title =
            'CURRENT PHONE DIRECTION: ${current8Zone.direction} (${heading.round()}°) — ${current8Zone.sanskritName.split('(').first.trim().toUpperCase()}';
        subtitle =
            'Ideal: ${current8Zone.plainLabel} • ${current8Zone.elementLabel}';
        colorVal = current8Zone.colorValue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(colorVal).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(colorVal).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.explore_rounded, color: Color(colorVal), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(colorVal),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: theme.textPrimary, fontSize: 9.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeContent({
    required VastuGridMode mode,
    required VastuProfileType profile,
    required dynamic state,
    required dynamic controller,
    required dynamic proState,
    required VastuZoneInfo current8Zone,
    required Vastu16ZoneInfo current16Zone,
    required Vastu32ZoneInfo current32Zone,
    required CompassTheme theme,
  }) {
    if (profile == VastuProfileType.commercial) {
      return _buildCommercialList(state, controller, theme);
    }

    switch (mode) {
      case VastuGridMode.sixteenZone:
        return _build16ZoneList(current16Zone, theme);
      case VastuGridMode.thirtyTwoZone:
        return _build32ZoneList(current32Zone, theme);
      case VastuGridMode.eightZone:
      default:
        return _build8ZoneView(state, controller, current8Zone, theme);
    }
  }

  // 16-Zone Shodasha Mandala Interactive List (FREE)
  Widget _build16ZoneList(Vastu16ZoneInfo current16, CompassTheme theme) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: VastuCalculator.sixteenZones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final zone = VastuCalculator.sixteenZones[index];
        final isAiming = zone.code == current16.code;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAiming
                ? const Color(0xFFFFD700).withOpacity(0.12)
                : theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAiming ? const Color(0xFFFFD700) : theme.dialRing,
              width: isAiming ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isAiming
                      ? const Color(0xFFFFD700)
                      : Color(zone.colorValue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  zone.code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isAiming ? Colors.black : Color(zone.colorValue),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${zone.name} (${zone.centerDegrees.toStringAsFixed(1)}°)',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (isAiming)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CURRENT ➔',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zone.attribute,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ideal: ${zone.recommendedUsage}',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'Avoid: ${zone.avoidUsage}',
                      style: TextStyle(
                        color: theme.northRed.withOpacity(0.85),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 32-Zone Vastu Purusha Mandala Door Padas (PRO)
  Widget _build32ZoneList(Vastu32ZoneInfo current32, CompassTheme theme) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: VastuCalculator.thirtyTwoZones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final pada = VastuCalculator.thirtyTwoZones[index];
        final isAiming = pada.padaCode == current32.padaCode;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAiming
                ? Color(pada.suitability.colorValue).withOpacity(0.15)
                : theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAiming
                  ? Color(pada.suitability.colorValue)
                  : theme.dialRing,
              width: isAiming ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Color(pada.suitability.colorValue).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pada.padaCode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(pada.suitability.colorValue),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pada.deityName} • ${pada.quadrant}',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAiming) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CURRENT ➔',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Color(pada.suitability.colorValue)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pada.suitability.label,
                                style: TextStyle(
                                  color: Color(pada.suitability.colorValue),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Traditional Effect: ${pada.traditionalEffect}',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Commercial Guidelines List (PRO)
  Widget _buildCommercialList(
    dynamic state,
    dynamic controller,
    CompassTheme theme,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: VastuCalculator.commercialGuidelines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final guide = VastuCalculator.commercialGuidelines[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dialRing),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(guide.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ideal Direction: ${guide.idealDirection}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                guide.plainPurpose,
                style: TextStyle(color: theme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                'Business Impact: ${guide.businessImpact}',
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 8-Direction View with 3x3 House Matrix and Room Guidelines
  Widget _build8ZoneView(
    dynamic state,
    dynamic controller,
    VastuZoneInfo currentZone,
    CompassTheme theme,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        // 3x3 VASTU HOUSE FLOOR PLAN MATRIX
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Text(
                '3×3 DIRECTIONAL REFERENCE MATRIX (NORTH IS UP ↑)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'Directional reference showing ideal room quadrants around the central Brahmasthan. Not an actual architectural blueprint of your home. Tap any cell to view room directives.',
          style: TextStyle(
            color: theme.textSecondary.withOpacity(0.85),
            fontSize: 9.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),

        // Visual 3x3 Grid
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dialRing),
          ),
          child: Column(
            children: [
              _buildGridRow(
                [
                  VastuCalculator.houseGrid[0], // NW
                  VastuCalculator.houseGrid[1], // N
                  VastuCalculator.houseGrid[2], // NE
                ],
                currentZone.direction,
                theme,
              ),
              const SizedBox(height: 5),
              _buildGridRow(
                [
                  VastuCalculator.houseGrid[3], // W
                  VastuCalculator.houseGrid[4], // CENTER
                  VastuCalculator.houseGrid[5], // E
                ],
                currentZone.direction,
                theme,
              ),
              const SizedBox(height: 5),
              _buildGridRow(
                [
                  VastuCalculator.houseGrid[6], // SW
                  VastuCalculator.houseGrid[7], // S
                  VastuCalculator.houseGrid[8], // SE
                ],
                currentZone.direction,
                theme,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

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

        // Room Guidelines List
        ...VastuCalculator.roomGuidelines.map((guide) {
          final isBeaconActive = state.activeVastuRoom == guide.type;
          final isSelected = _selectedRoom == guide.type || isBeaconActive;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBeaconActive
                  ? const Color(0xFFFFD700).withOpacity(0.16)
                  : (isSelected
                        ? const Color(0xFFFFD700).withOpacity(0.08)
                        : theme.background),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isBeaconActive
                    ? const Color(0xFFFFD700)
                    : (isSelected
                          ? const Color(0xFFFFD700).withOpacity(0.6)
                          : theme.dialRing),
                width: isBeaconActive ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBeaconActive) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              size: 10,
                              color: Colors.black,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'TARGET BEACON ACTIVE',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    Text(guide.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ideal: ${guide.idealDirection} (${guide.targetHeading.round()}°)',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBeaconActive
                            ? theme.northRed.withOpacity(0.9)
                            : const Color(0xFFFFD700),
                        foregroundColor: isBeaconActive
                            ? Colors.white
                            : Colors.black,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      icon: Icon(
                        isBeaconActive
                            ? Icons.cancel_rounded
                            : Icons.navigation_rounded,
                        size: 13,
                      ),
                      onPressed: () {
                        if (isBeaconActive) {
                          controller.setActiveVastuRoom(null);
                        } else {
                          controller.setActiveVastuRoom(guide.type);
                          if (!state.isVastuMode) {
                            controller.toggleVastuMode();
                          }
                        }
                        Navigator.pop(context);
                      },
                      label: Text(
                        isBeaconActive ? 'CLEAR BEACON' : 'AIM NEEDLE',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  guide.plainPurpose,
                  style: TextStyle(color: theme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  isBeaconActive
                      ? '🎯 Compass needle tracks ${guide.targetHeading.round()}° on the main dial. Align top needle with target marker.'
                      : 'Tap "AIM NEEDLE" to set a target beacon on the compass dial and steer towards this room.',
                  style: TextStyle(
                    color: isBeaconActive
                        ? const Color(0xFFFFD700)
                        : theme.textSecondary.withOpacity(0.7),
                    fontSize: 9.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGridRow(
    List<VastuGridCell> cells,
    String currentDirection,
    CompassTheme theme,
  ) {
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
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: isCurrentPointing
                    ? const Color(0xFFFFD700).withOpacity(0.24)
                    : (isCenter ? theme.surfaceElevated : theme.surface),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrentPointing
                      ? const Color(0xFFFFD700)
                      : (isCenter
                            ? const Color(0xFFFFD700).withOpacity(0.4)
                            : theme.dialRing),
                  width: isCurrentPointing ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${cell.emoji} ${cell.label}',
                      style: TextStyle(
                        color: isCurrentPointing
                            ? const Color(0xFFFFD700)
                            : (isCenter
                                  ? const Color(0xFFFFD700)
                                  : Color(cell.colorValue)),
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
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
