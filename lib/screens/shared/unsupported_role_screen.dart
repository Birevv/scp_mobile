import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/headers/header_with_gradient.dart';

class UnsupportedRoleScreen extends StatelessWidget {
  final AppState state;

  const UnsupportedRoleScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final roleLabel =
        user.roleBadge.isNotEmpty ? user.roleBadge : user.role.title;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HeaderWithGradient(
            isDashboard: true,
            greeting: 'Halo,',
            userName: user.name,
            userSubtitle: '$roleLabel • ${user.identifier}',
            badgeText: 'PANEL WEB SCP',
            avatarUrl: user.avatarUrl,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SoftCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                borderRadius: AppSpacing.radiusLarge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.lightIndigoBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.desktop_windows_rounded,
                        color: AppColors.primaryIndigo,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Akses Aplikasi Mobile Belum Tersedia untuk Role Ini',
                      style: AppTypography.sectionTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Akun Anda terdaftar sebagai "$roleLabel". Pengelolaan kurikulum, manajemen master data, dan administrasi sistem untuk role ini diakses melalui Panel Web School Class Progress (SCP) SMK Negeri 1 Bantul.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Keluar dari Akun (Logout)',
                      icon: Icons.logout_rounded,
                      backgroundColor: AppColors.statusAlpa,
                      onPressed: () async {
                        await state.logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

