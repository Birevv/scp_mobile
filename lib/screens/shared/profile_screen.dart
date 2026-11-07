import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/buttons/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    required this.state,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileModal() {
    final user = widget.state.currentUser;
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Perbarui Profil Pengguna', style: AppTypography.sectionTitle),
              const SizedBox(height: 4),
              Text(
                'Sinkronisasi data nama dan email akun SCP Anda.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Nama Lengkap', style: AppTypography.cardTitle),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Email Sekolah', style: AppTypography.cardTitle),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, size: 19),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Simpan Perubahan',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty &&
                      emailCtrl.text.trim().isNotEmpty) {
                    final res = await widget.state.updateProfileOnServer(
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.success
                            ? 'Profil berhasil diperbarui!'
                            : res.message),
                        backgroundColor: res.success
                            ? AppColors.statusHadir
                            : AppColors.statusAlpa,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Ganti Kata Sandi', style: AppTypography.sectionTitle),
                const SizedBox(height: 4),
                Text(
                  'Gunakan minimal 8 karakter kombinasi huruf dan angka.',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Kata Sandi Saat Ini', style: AppTypography.cardTitle),
                const SizedBox(height: 6),
                TextField(
                  controller: oldPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan kata sandi lama',
                    prefixIcon: Icon(Icons.lock_outline_rounded, size: 19),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Kata Sandi Baru (Min. 8 Karakter)',
                  style: AppTypography.cardTitle,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Minimal 8 karakter',
                    prefixIcon: Icon(Icons.key_rounded, size: 19),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Konfirmasi Kata Sandi Baru',
                  style: AppTypography.cardTitle,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Ulangi kata sandi baru',
                    prefixIcon: Icon(Icons.verified_user_outlined, size: 19),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Perbarui Kata Sandi',
                  icon: Icons.save_outlined,
                  onPressed: () async {
                    if (oldPassCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi saat ini wajib diisi!'),
                          backgroundColor: AppColors.statusAlpa,
                        ),
                      );
                      return;
                    }
                    if (newPassCtrl.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password baru wajib minimal 8 karakter!',
                          ),
                          backgroundColor: AppColors.statusAlpa,
                        ),
                      );
                      return;
                    }
                    if (newPassCtrl.text != confirmPassCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Konfirmasi password tidak cocok!'),
                          backgroundColor: AppColors.statusAlpa,
                        ),
                      );
                      return;
                    }
                    final res = await widget.state.changePasswordOnServer(
                      currentPassword: oldPassCtrl.text,
                      newPassword: newPassCtrl.text,
                      newPasswordConfirmation: confirmPassCtrl.text,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.success
                            ? 'Password akun berhasil diperbarui!'
                            : res.message),
                        backgroundColor: res.success
                            ? AppColors.statusHadir
                            : AppColors.statusAlpa,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi Keluar', style: AppTypography.sectionTitle),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi SCP Mobile SMK Negeri 1 Bantul?',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusAlpa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.state.logout();
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWithGradient(
              isDashboard: true,
              greeting: 'Profil Pengguna,',
              userName: user.name,
              userSubtitle: '${user.role.title} • ${user.className}',
              badgeText: '${widget.state.activeCycle.label} Aktif',
              avatarUrl: user.avatarUrl,
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Identity Card
                  SoftCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: AppSpacing.radiusLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryIndigo,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.lightIndigoBg,
                                backgroundImage: user.avatarUrl.isNotEmpty
                                    ? NetworkImage(user.avatarUrl)
                                    : null,
                                child: user.avatarUrl.isEmpty
                                    ? Text(
                                        user.name[0],
                                        style: AppTypography.pageTitle.copyWith(
                                          color: AppColors.primaryIndigo,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: AppTypography.sectionTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightIndigoBg,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusPill,
                                      ),
                                    ),
                                    child: Text(
                                      user.role.title,
                                      style: AppTypography.microBadge.copyWith(
                                        color: AppColors.primaryIndigo,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.identifier,
                                    style: AppTypography.smallHint.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 14),
                        _buildInfoRow('Email Sekolah', user.email),
                        const SizedBox(height: 10),
                        _buildInfoRow('Kelas / Penugasan', user.className),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          'Instansi',
                          'SMK Negeri 1 Bantul',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text('Pengaturan & Keamanan', style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),

                  SoftCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppSpacing.radiusLarge,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightIndigoBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryIndigo,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Ubah Profil & Data Diri',
                            style: AppTypography.cardTitle,
                          ),
                          subtitle: Text(
                            'Perbarui nama lengkap dan email akun',
                            style: AppTypography.caption,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onTap: _showEditProfileModal,
                        ),
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.border,
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightTealBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.secondaryTeal,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Ganti Kata Sandi',
                            style: AppTypography.cardTitle,
                          ),
                          subtitle: Text(
                            'Ubah password keamanan akun SCP',
                            style: AppTypography.caption,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onTap: _showChangePasswordModal,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusRejectedBg,
                        foregroundColor: AppColors.statusAlpa,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLarge),
                          side: BorderSide(
                            color: AppColors.statusAlpa.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.statusAlpa,
                      ),
                      label: Text(
                        'Keluar dari Akun (Logout)',
                        style: AppTypography.labelButton.copyWith(
                          color: AppColors.statusAlpa,
                        ),
                      ),
                      onPressed: _handleLogoutDialog,
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.smallHint),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.smallHint.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
