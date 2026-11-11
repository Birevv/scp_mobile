import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'cards/soft_card.dart';

class MenuItemData {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;
  final String? badge;
  final bool isLocked;
  final String? subtitle;

  const MenuItemData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.onTap,
    this.badge,
    this.isLocked = false,
    this.subtitle,
  });
}

/// MenuGrid - Grid Akses Cepat
/// Mendukung layout responsif:
/// - 4 menu: 1 baris 4 menu rata
/// - 5 menu: 3 menu di baris pertama, 2 menu di baris kedua
/// - 8 menu: 2 baris x 4 menu rata
/// - Lainnya: Wrap dengan distribusi proporsional
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
    if (items.isEmpty) return const SizedBox.shrink();

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
                bottom: 16,
              ),
              child: Text(
                sectionTitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],

          LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;

              // Bila 4 menu: 1 baris 4 menu rata
              if (items.length == 4) {
                final double itemWidth = (totalWidth - 24) / 4;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
                      .map((item) => _buildGridItem(context, item, itemWidth))
                      .toList(),
                );
              }

              // Bila 5 menu: 3 menu di atas, 2 menu di bawah
              if (items.length == 5) {
                final topItems = items.sublist(0, 3);
                final bottomItems = items.sublist(3, 5);
                final double itemWidth = (totalWidth - 16) / 3;

                return Column(
                  children: [
                    // Baris 1: 3 Menu di Atas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: topItems
                          .map((item) => _buildGridItem(context, item, itemWidth))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Baris 2: 2 Menu di Bawah (Seimbang & Proporsional)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bottomItems
                          .map((item) => _buildGridItem(context, item, itemWidth))
                          .toList(),
                    ),
                  ],
                );
              }

              // Bila 8 menu: 2 baris x 4 menu rata
              if (items.length == 8) {
                final topItems = items.sublist(0, 4);
                final bottomItems = items.sublist(4, 8);
                final double itemWidth = (totalWidth - 24) / 4;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: topItems
                          .map((item) => _buildGridItem(context, item, itemWidth))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bottomItems
                          .map((item) => _buildGridItem(context, item, itemWidth))
                          .toList(),
                    ),
                  ],
                );
              }

              // Default fallback bila jumlah item berbeda
              final int columns = items.length <= 3 ? items.length : 4;
              final double itemWidth = (totalWidth - (8.0 * (columns - 1))) / columns;

              return Wrap(
                spacing: 8.0,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: items
                    .map((item) => _buildGridItem(context, item, itemWidth))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, MenuItemData item, double width) {
    final bool effectiveLocked = item.isLocked || item.onTap == null;
    final Color effectiveIconColor =
        effectiveLocked ? AppColors.textTertiary : item.iconColor;
    final Color effectiveBgColor =
        effectiveLocked ? AppColors.background : item.bgColor;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveLocked ? null : item.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon,
                          color: effectiveIconColor,
                          size: 24,
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
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusError,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            item.badge!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
