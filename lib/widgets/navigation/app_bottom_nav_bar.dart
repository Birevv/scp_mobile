import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? badge;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<AppBottomNavItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final int safeIndex = currentIndex.clamp(0, items.length - 1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 0,
        bottom: bottomInset > 0 ? bottomInset + 4 : 8,
        left: 4,
        right: 4,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth / items.length;
          final double indicatorWidth = 24.0;
          final double indicatorLeft =
              (safeIndex * itemWidth) + (itemWidth - indicatorWidth) / 2;

          return Stack(
            children: [
              // Single Smooth Sliding Top Indicator
              // Menjamin hanya ada 1 indikator aktif tanpa artefak ghosting atau titik sisa
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                top: 0,
                width: indicatorWidth,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigo,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),

              // Navigation Items Row
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Row(
                  children: items.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final AppBottomNavItem item = entry.value;
                    final bool isSelected = index == safeIndex;

                    return Expanded(
                      child: InkWell(
                        onTap: () => onIndexChanged(index),
                        borderRadius: BorderRadius.circular(12),
                        splashColor:
                            AppColors.primaryIndigo.withValues(alpha: 0.08),
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? (item.activeIcon ?? item.icon)
                                          : item.icon,
                                      size: 23,
                                      color: isSelected
                                          ? AppColors.primaryIndigo
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (item.badge != null)
                                    Positioned(
                                      top: -2,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorAlpa,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusPill,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          item.badge!,
                                          style:
                                              AppTypography.microBadge.copyWith(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                style: AppTypography.microBadge.copyWith(
                                  color: isSelected
                                      ? AppColors.primaryIndigo
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
