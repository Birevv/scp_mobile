import 'package:flutter/material.dart';
import '../constants/lucide_icons.dart';
import '../theme/app_theme.dart';

class DoubleFilterPills extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;
  final IconData? leftIcon;
  final IconData? rightIcon;

  const DoubleFilterPills({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    this.onLeftTap,
    this.onRightTap,
    this.leftIcon = LucideIcons.calendar,
    this.rightIcon = LucideIcons.layers,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPill(
            context: context,
            label: leftLabel,
            icon: leftIcon,
            onTap: onLeftTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildPill(
            context: context,
            label: rightLabel,
            icon: rightIcon,
            onTap: onRightTap,
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required String label,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
