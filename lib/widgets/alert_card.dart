import 'package:flutter/material.dart';
import '../constants/lucide_icons.dart';
import '../theme/app_theme.dart';

enum AlertSeverity {
  danger(AppTheme.danger, AppTheme.dangerBg, 'PERINGATAN JURNAL'),
  warning(AppTheme.warning, AppTheme.warningBg, 'PENGINGAT PRESENSI'),
  info(AppTheme.primaryBlue, AppTheme.tintBackground, 'INFORMASI SIKLUS');

  final Color primaryColor;
  final Color bgColor;
  final String tag;
  const AlertSeverity(this.primaryColor, this.bgColor, this.tag);
}

class AlertCard extends StatelessWidget {
  final AlertSeverity severity;
  final String title;
  final String description;
  final String timeElapsed;
  final String? actionButtonText;
  final VoidCallback? onActionTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    this.severity = AlertSeverity.danger,
    required this.title,
    required this.description,
    required this.timeElapsed,
    this.actionButtonText,
    this.onActionTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: severity.bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: severity.primaryColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: severity.primaryColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: severity.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  severity == AlertSeverity.danger ? LucideIcons.alertTriangle : LucideIcons.bell,
                  size: 16,
                  color: severity.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severity.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  severity.tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: severity.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, size: 10, color: severity.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      timeElapsed,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: severity.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 14, color: AppTheme.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDismiss,
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textBody,
              height: 1.3,
            ),
          ),

          if (actionButtonText != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: severity.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.edit3, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      actionButtonText!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
