import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../buttons/primary_button.dart';
import 'soft_card.dart';

class DataLoadingCard extends StatelessWidget {
  final String message;

  const DataLoadingCard({
    super.key,
    this.message = 'Memuat data dari server...',
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 32,
      ),
      borderRadius: AppSpacing.radiusLarge,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: AppColors.primaryIndigo,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: AppTypography.smallHint.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DataErrorCard extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback onRetry;

  const DataErrorCard({
    super.key,
    this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppSpacing.radiusLarge,
      border: Border.all(
        color: AppColors.statusAlpa.withValues(alpha: 0.35),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.statusRejectedBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.statusAlpa,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title ?? 'Gagal Memuat Data',
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTypography.smallHint.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Muat Ulang',
            icon: Icons.refresh_rounded,
            width: 170,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class DataEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const DataEmptyCard({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 28,
      ),
      borderRadius: AppSpacing.radiusLarge,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.lightIndigoBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryIndigo,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.smallHint.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

