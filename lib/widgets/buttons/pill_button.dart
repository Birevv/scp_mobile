import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';

class PillButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final String? count;
  final Color? activeColor;
  final IconData? icon;

  const PillButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.count,
    this.activeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primaryIndigo;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? effectiveActiveColor : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: isActive
                ? null
                : Border.all(color: AppColors.border, width: 1),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: effectiveActiveColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                count != null ? '$label ($count)' : label,
                style: AppTypography.labelButton.copyWith(
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
