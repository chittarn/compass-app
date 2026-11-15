import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TelemetryGuideModal extends StatelessWidget {
  const TelemetryGuideModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TelemetryGuideModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.accentCyan, width: 1.5),
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
                color: AppColors.textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.accentCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'FIELD GUIDE & GLOSSARY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.background, height: 1),

          // Content List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildSection(
                  icon: Icons.explore_rounded,
                  iconColor: AppColors.accentCyan,
                  title: 'HEADING: MAGNETIC VS. TRUE NORTH',
                  content: [
                    _buildItem(
                      term: 'Magnetic North (🧲)',
                      explanation:
                          'Points directly to Earth\'s wandering magnetic north pole using your device\'s magnetometer sensor. Works offline, in airplane mode, and requires zero GPS or data connection.',
                    ),
                    _buildItem(
                      term: 'True North (🌐)',
                      explanation:
                          'Points to the exact Geographic North Pole (Earth\'s rotational axis at 90°N). Uses your GPS coordinates to compute the magnetic declination offset. Essential for aligning with printed topographic maps and aviation/nautical navigation.',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.screen_rotation_rounded,
                  iconColor: AppColors.accentGreen,
                  title: 'INCLINOMETER & 2D BUBBLE LEVEL',
                  content: [
                    _buildItem(
                      term: 'Pitch',
                      explanation:
                          'Measures the front-to-back tilt angle (nose up or down). Tilt values range from -90° to +90°.',
                    ),
                    _buildItem(
                      term: 'Roll',
                      explanation:
                          'Measures the side-to-side rotation (lateral wing dip left or right). Tilt values range from -180° to +180°.',
                    ),
                    _buildItem(
                      term: 'Level Status (±1.5° Deadband)',
                      explanation:
                          'LEVEL (Green): The phone is held flat on the horizontal plane. Magnetic heading is at peak physical accuracy.\nTILTED (Amber): Tilt exceeds ±1.5°. Electronic magnetometers experience 3D gimbal distortion when tilted off-axis.',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.tune_rounded,
                  iconColor: AppColors.accentAmber,
                  title: 'SENSOR ACCURACY & CALIBRATION',
                  content: [
                    _buildItem(
                      term: 'Accuracy Pill Badge',
                      explanation:
                          'Displays the real-time sensor health: HIGH, MEDIUM, LOW, or UNRELIABLE. Reflects the hardware magnetometer\'s confidence level.',
                    ),
                    _buildItem(
                      term: 'Figure-8 Calibration',
                      explanation:
                          'Magnetic phone cases, electronic gadgets, steel rebar, or car dashes cause magnetic distortion. When accuracy drops, tap the accuracy badge and wave your phone in a 3D figure-8 motion to recalibrate.',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.vibration_rounded,
                  iconColor: AppColors.northRed,
                  title: 'TACTICAL HAPTIC FEEDBACK',
                  content: [
                    _buildItem(
                      term: 'Sensory Guidance',
                      explanation:
                          '• Light Click: Every 15° tick mark crossed.\n• Medium Pulse: Major cardinal directions (East 090°, South 180°, West 270°).\n• Heavy Sharp Pulse: True/Magnetic North (000°).\n\nEquipped with velocity suppression to prevent haptic stutter during fast spins.',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Widget _buildItem({required String term, required String explanation}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.9),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
