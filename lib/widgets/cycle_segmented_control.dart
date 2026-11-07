import 'package:flutter/material.dart';
import '../constants/lucide_icons.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CycleSegmentedControl extends StatelessWidget {
  final CycleType activeCycle;
  final ValueChanged<CycleType> onCycleChanged;
  final bool isInteractive;

  const CycleSegmentedControl({
    super.key,
    required this.activeCycle,
    required this.onCycleChanged,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(
        radius: AppTheme.radiusLarge,
        shadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              context: context,
              cycle: CycleType.putaran1,
              isSelected: activeCycle == CycleType.putaran1,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildSegment(
              context: context,
              cycle: CycleType.putaran2,
              isSelected: activeCycle == CycleType.putaran2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required CycleType cycle,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: isInteractive ? () => onCycleChanged(cycle) : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: isSelected ? AppTheme.buttonShadow : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cycle == CycleType.putaran1 ? LucideIcons.rotateCcw : LucideIcons.rotateCw,
                  size: 15,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  cycle.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              cycle == CycleType.putaran1 ? 'Minggu Blok 1 & 2' : 'Minggu Blok 3 & 4',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
