import 'package:flutter/material.dart';
import '../constants/lucide_icons.dart';
import '../theme/app_theme.dart';

class LockBanner extends StatelessWidget {
  final bool isLocked;
  final String? lockedBy;
  final VoidCallback? onInfoTap;

  const LockBanner({
    super.key,
    required this.isLocked,
    this.lockedBy = 'Waka Kurikulum',
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Soft warm amber
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB300),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.lock,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Jadwal Telah Dikunci',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
                Text(
                  'Perubahan jadwal dinonaktifkan oleh $lockedBy.',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFBF360C),
                  ),
                ),
              ],
            ),
          ),
          if (onInfoTap != null)
            IconButton(
              icon: const Icon(LucideIcons.info, size: 16, color: Color(0xFFE65100)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onInfoTap,
            ),
        ],
      ),
    );
  }
}
