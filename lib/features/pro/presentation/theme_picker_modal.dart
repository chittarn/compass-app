import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/pro_controller.dart';
import 'pro_upgrade_modal.dart';

class ThemePickerModal extends ConsumerWidget {
  const ThemePickerModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemePickerModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proState = ref.watch(proControllerProvider);
    final proNotifier = ref.read(proControllerProvider.notifier);
    final theme = proState.effectiveTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: proState.isPro ? theme.accentCyan : theme.goldPro,
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: theme.accentCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: theme.accentCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TACTICAL THEMES',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Scotopic preservation & high-contrast styles',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 11,
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

              const SizedBox(height: 14),

              // Theme Cards
              ...AppThemeMode.values.map((mode) {
                final isSelected =
                    (mode == AppThemeMode.nightVision &&
                        proState.isNightVision) ||
                    (!proState.isNightVision && proState.themeMode == mode);
                final isProTheme = mode != AppThemeMode.tacticalDark;
                final isLocked = isProTheme && !proState.isPro;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      if (isLocked) {
                        Navigator.of(context).pop();
                        ProUpgradeModal.show(context);
                      } else {
                        proNotifier.setTheme(mode);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${mode.label}'),
                            backgroundColor: theme.surfaceElevated,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mode.primaryColor.withOpacity(0.12)
                            : theme.surfaceElevated.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? mode.primaryColor
                              : theme.textSecondary.withOpacity(0.2),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Color Swatch Badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: mode == AppThemeMode.nightVision
                                  ? Colors.black
                                  : (mode == AppThemeMode.arcticCyan
                                        ? const Color(0xFF081016)
                                        : (mode == AppThemeMode.tacticalAmber
                                              ? const Color(0xFF100E08)
                                              : const Color(0xFF0F1115))),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: mode.primaryColor,
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: mode.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Title and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      mode.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? mode.primaryColor
                                            : theme.textPrimary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (!isProTheme)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.accentCyan.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'FREE',
                                          style: TextStyle(
                                            color: theme.accentCyan,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.goldPro.withOpacity(
                                            0.18,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: theme.goldPro,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mode.description,
                                  style: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // State Indicator: Selected Check or Lock
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: mode.primaryColor,
                              size: 20,
                            )
                          else if (isLocked)
                            Icon(
                              Icons.lock_rounded,
                              color: theme.goldPro,
                              size: 18,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: theme.textSecondary.withOpacity(0.4),
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
