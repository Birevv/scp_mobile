import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../buttons/primary_button.dart';

class ScheduleConflictBottomSheet extends StatelessWidget {
  final String title;
  final String conflictDescription;
  final String? conflictType; // 'Ruangan', 'Guru', 'Kelas'
  final VoidCallback onChangeSchedule;
  final VoidCallback onCancel;

  const ScheduleConflictBottomSheet({
    super.key,
    this.title = 'Peringatan Jadwal Bentrok!',
    required this.conflictDescription,
    this.conflictType,
    required this.onChangeSchedule,
    required this.onCancel,
  });

  static Future<void> show({
    required BuildContext context,
    required String conflictDescription,
    String? conflictType,
    required VoidCallback onChangeSchedule,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScheduleConflictBottomSheet(
        conflictDescription: conflictDescription,
        conflictType: conflictType,
        onChangeSchedule: () {
          Navigator.pop(ctx);
          onChangeSchedule();
        },
        onCancel: () {
          Navigator.pop(ctx);
          if (onCancel != null) onCancel();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXL),
          topRight: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Alert Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.alertRedBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.errorAlpa,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                title,
                style: AppTypography.sectionTitle.copyWith(
                  color: const Color(0xFF991B1B),
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              if (conflictType != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.alertRedBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    'Bentrok: $conflictType',
                    style: AppTypography.microBadge.copyWith(
                      color: AppColors.errorAlpa,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: const Color(0xFFFEE2E2),
                    width: 1,
                  ),
                ),
                child: Text(
                  conflictDescription,
                  style: AppTypography.bodyText.copyWith(
                    color: const Color(0xFF991B1B),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              PrimaryButton(
                label: 'Ubah Jam / Ruangan',
                backgroundColor: AppColors.errorAlpa,
                onPressed: onChangeSchedule,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Batalkan',
                    style: AppTypography.labelButton.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
