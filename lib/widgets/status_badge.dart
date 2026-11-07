import 'package:flutter/material.dart';
import '../constants/lucide_icons.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;
  final bool isSmall;
  final bool isAutoSynced;

  const StatusBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.icon,
    this.isSmall = false,
    this.isAutoSynced = false,
  });

  factory StatusBadge.fromAttendance(AttendanceStatus status, {bool isSmall = false, bool isAutoSynced = false}) {
    IconData? iconData;
    switch (status) {
      case AttendanceStatus.hadir:
        iconData = LucideIcons.checkCircle;
        break;
      case AttendanceStatus.izin:
        iconData = LucideIcons.fileText;
        break;
      case AttendanceStatus.sakit:
        iconData = LucideIcons.activity;
        break;
      case AttendanceStatus.alpa:
        iconData = LucideIcons.xCircle;
        break;
    }

    return StatusBadge(
      label: isAutoSynced ? '${status.label} (Auto)' : status.label,
      textColor: status.color,
      backgroundColor: status.bgColor,
      icon: iconData,
      isSmall: isSmall,
      isAutoSynced: isAutoSynced,
    );
  }

  factory StatusBadge.fromLeave(LeaveStatus status, {bool isSmall = false}) {
    IconData? iconData;
    switch (status) {
      case LeaveStatus.pending:
        iconData = LucideIcons.clock;
        break;
      case LeaveStatus.approved:
        iconData = LucideIcons.check;
        break;
      case LeaveStatus.rejected:
        iconData = LucideIcons.x;
        break;
    }

    return StatusBadge(
      label: status.label,
      textColor: status.color,
      backgroundColor: status.bgColor,
      icon: iconData,
      isSmall: isSmall,
    );
  }

  factory StatusBadge.cycle(CycleType cycle) {
    return StatusBadge(
      label: cycle.label,
      textColor: AppTheme.primaryBlue,
      backgroundColor: AppTheme.tintBackground,
      icon: LucideIcons.refreshCw,
      isSmall: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 11 : 13,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isAutoSynced) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.zap,
                size: 8,
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
