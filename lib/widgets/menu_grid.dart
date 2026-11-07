import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'cards/soft_card.dart';

class MenuItemData {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;
  final String? badge;
  final bool isLocked;

  const MenuItemData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.onTap,
    this.badge,
    this.isLocked = false,
  });
}

class MenuGrid extends StatelessWidget {
  final List<MenuItemData> items;
  final String? sectionTitle;

  const MenuGrid({
    super.key,
    required this.items,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      borderRadius: AppSpacing.radiusLarge,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sectionTitle != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 14,
              ),
              child: Text(
                sectionTitle!,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              // 4 columns on standard smartphone widths, 2 columns on ultra-compact
              final int columns = constraints.maxWidth < 260 ? 2 : 4;
              final double spacing = 8.0;
              final double itemWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 14,
                children: items.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: _buildGridItem(context, item),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, MenuItemData item) {
    final bool effectiveLocked = item.isLocked || item.onTap == null;
    final Color effectiveIconColor =
        effectiveLocked ? AppColors.textTertiary : item.iconColor;
    final Color effectiveBgColor =
        effectiveLocked ? AppColors.background : const Color(0xFFF1F5F9);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveLocked ? null : item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: effectiveBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: effectiveLocked
                            ? AppColors.border
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: effectiveIconColor,
                        size: 23,
                      ),
                    ),
                  ),
                  if (item.isLocked)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    )
                  else if (item.badge != null)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusAlpa,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          item.badge!,
                          style: AppTypography.microBadge.copyWith(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: AppTypography.microBadge.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: effectiveLocked
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
