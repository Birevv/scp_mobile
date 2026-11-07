import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';

enum AlertType { success, warning, error, info }

class AlertCard extends StatelessWidget {
  final String message;
  final String? title;
  final AlertType type;
  final VoidCallback? onClose;
  final Widget? action;

  static const Map<AlertType, Color> _bgColors = {
    AlertType.success: AppColors.alertGreenBg,
    AlertType.warning: AppColors.alertAmberBg,
    AlertType.error: AppColors.alertRedBg,
    AlertType.info: AppColors.alertBlueBg,
  };

  static const Map<AlertType, Color> _textColors = {
    AlertType.success: Color(0xFF065F46),
    AlertType.warning: Color(0xFFB45309),
    AlertType.error: Color(0xFF991B1B),
    AlertType.info: Color(0xFF0C4A6E),
  };

  static const Map<AlertType, Color> _iconColors = {
    AlertType.success: AppColors.successHadir,
    AlertType.warning: AppColors.warningSakit,
    AlertType.error: AppColors.errorAlpa,
    AlertType.info: AppColors.infoIzin,
  };

  const AlertCard({
    super.key,
    required this.message,
    this.title,
    required this.type,
    this.onClose,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bgColors[type],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: _iconColors[type]!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _iconColors[type],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _getAlertIcon(type),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: AppTypography.cardTitle.copyWith(
                          color: _textColors[type],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: AppTypography.smallHint.copyWith(
                        color: _textColors[type],
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 16, color: _textColors[type]),
                  ),
                ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }

  Widget _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.success:
        return const Icon(Icons.check_circle, color: Colors.white, size: 18);
      case AlertType.warning:
        return const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18);
      case AlertType.error:
        return const Icon(Icons.error_outline, color: Colors.white, size: 18);
      case AlertType.info:
        return const Icon(Icons.info_outline, color: Colors.white, size: 18);
    }
  }
}
