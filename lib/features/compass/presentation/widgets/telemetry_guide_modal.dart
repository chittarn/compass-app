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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
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
                const SizedBox(width: 10),
                const Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'FIELD GUIDE & GLOSSARY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
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
                const SizedBox(height: 16),
                _buildSection(
                  icon: Icons.mosque_rounded,
                  iconColor: const Color(0xFF00E676),
                  title: 'QIBLA MODE (MECCA AZIMUTH & DISTANCE)',
                  content: [
                    _buildItem(
                      term: 'Kaaba Direction (🕋)',
                      explanation:
                          'Calculates the exact spherical great-circle bearing from your GPS position directly to the Holy Kaaba in Mecca (21.4225°N, 39.8262°E). The emerald green Kaaba marker on the dial rim shows you the exact bearing.',
                    ),
                    _buildItem(
                      term: 'Alignment Vibration Pulse',
                      explanation:
                          'When your phone points directly at the Kaaba (within ±3°), the dial lights up with a green glow and triggers a tactile haptic pulse.',
                    ),
                    _buildItem(
                      term: 'Geodesic Distance',
                      explanation:
                          'Displays the real-time distance in kilometers to Mecca calculated via the WGS-84 Haversine geodesic model.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.goldPro,
                  title: 'MAGNETIC FIELD METER & EMF STUD DETECTOR (μT)',
                  content: [
                    _buildItem(
                      term: 'Magnetic Flux Density (Microteslas)',
                      explanation:
                          'Earth\'s natural ambient magnetic field typically measures between 30 μT and 60 μT. Readout updates live with low-pass noise filtering.',
                    ),
                    _buildItem(
                      term: 'Interference & Metal Stud Detection',
                      explanation:
                          '• 30–65 μT: NORMAL ambient Earth field.\n• 65–110 μT: ELEVATED magnetic fields (electronics or wiring nearby).\n• >110 μT: HIGH INTERFERENCE. Can be used as a handheld metal stud and ferrous material detector behind drywall, or indicates you should step away from steel objects for accurate compass navigation.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                _buildSection(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: const Color(0xFFFFD54F),
                  title: 'CELESTIAL TRACKER & SOLAR EPHEMERIS',
                  content: [
                    _buildItem(
                      term: 'Sun ☀️ & Moon 🌙 Azimuth',
                      explanation:
                          'Real-time astronomical positions computed 100% offline using standard NOAA ephemeris formulas. Displays live solar and lunar heading markers directly on the dial rim.',
                    ),
                    _buildItem(
                      term: 'Sunrise & Sunset Times',
                      explanation:
                          'Local official solar dawn and dusk computed geometrically from your GPS coordinates. Perfect for golden-hour photography, hiking safety, and dusk preparedness.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  icon: Icons.pin_drop_rounded,
                  iconColor: const Color(0xFF00E5FF),
                  title: 'WAYPOINT BACKTRACK ("FIND MY SPOT")',
                  content: [
                    _buildItem(
                      term: '1-Tap Spot Bookmark',
                      explanation:
                          'Bookmark where you parked your car, pitched your tent, or started your hike. Zero internet or map tiles required.',
                    ),
                    _buildItem(
                      term: 'Cyan Beacon Guiding Needle',
                      explanation:
                          'A high-visibility cyan needle appears on the dial rim with real-time distance. Align the needle with the 12 o\'clock index to walk straight back to your saved spot.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  icon: Icons.vibration_rounded,
                  iconColor: AppColors.northRed,
                  title: 'TACTICAL HAPTIC FEEDBACK',
                  content: [
                    _buildItem(
                      term: 'Sensory Guidance',
                      explanation:
                          '• Light Click: Every 15° tick mark crossed.\n• Medium Pulse: Major cardinal directions (East 090°, South 180°, West 270°).\n• Heavy Sharp Pulse: True/Magnetic North (000°) & Qibla alignment.\n\nEquipped with velocity suppression to prevent haptic stutter during fast spins.',
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
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
