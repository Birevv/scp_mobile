import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import 'header_background_pattern.dart';

/// Reusable Standardized Page Header for SCP Mobile
///
/// Digunakan secara konsisten pada seluruh halaman utama (Jadwal Pelajaran,
/// Perizinan Saya, Riwayat Kehadiran) sesuai spesifikasi desain PRD/UX:
/// - Background: #203F91
/// - Horizontal padding: 20 px
/// - Vertical padding: 18-20 px (memperhitungkan notch/status bar)
/// - Title: 22 px, font weight 600-700
/// - Subtitle: 14 px, regular (format: `${studentName} • ${className}`)
/// - Badge: 12 px, semibold, background #079F92, border radius 999 px
/// - Spacing: title-to-badge 8 px, title-to-subtitle 6 px
/// - Bottom corner radius: 24 px
/// - Dynamic height (tanpa fixed height), anti-overflow pada layar sempit
class ScpPageHeader extends StatelessWidget {
  /// Judul halaman (e.g. 'Jadwal Pelajaran', 'Perizinan Saya', 'Riwayat Kehadiran')
  final String title;

  /// Nama siswa yang sedang login (e.g. 'BIMA REVAN SAPUTRA')
  final String studentName;

  /// Nama kelas aktif (e.g. 'XII RPL 2')
  final String className;

  /// Label putaran blok (e.g. 'Putaran 1', 'Putaran 2')
  final String? cycleLabel;

  /// Flag pengontrol visibilitas badge putaran
  final bool showCycleBadge;

  /// Widget opsional di sisi kiri (e.g. tombol kembali jika digunakan sebagai subhalaman)
  final Widget? leading;

  /// Widget opsional di sisi kanan (e.g. tombol filter atau aksi cepat)
  final Widget? actionButton;

  /// Widget opsional di bawah subtitle (e.g. filter pills tambahan)
  final Widget? bottomChild;

  const ScpPageHeader({
    super.key,
    required this.title,
    required this.studentName,
    required this.className,
    this.cycleLabel,
    this.showCycleBadge = true,
    this.leading,
    this.actionButton,
    this.bottomChild,
  });

  /// Format subtitle konsisten: `BIMA REVAN SAPUTRA • XII RPL 2`
  String get formattedSubtitle {
    final cleanName = studentName.trim();
    final cleanClass = className.trim();
    if (cleanName.isNotEmpty && cleanClass.isNotEmpty) {
      return '$cleanName • $cleanClass';
    } else if (cleanName.isNotEmpty) {
      return cleanName;
    } else {
      return cleanClass;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final effectiveTop = topPad > 0 ? topPad + 18.0 : 20.0;
    final bool shouldDisplayBadge = showCycleBadge &&
        cycleLabel != null &&
        cycleLabel!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.pageHeaderBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            // Background Curved Geometry Pattern (Design System Resmi)
            const Positioned.fill(
              child: HeaderBackgroundPattern(),
            ),
            // Foreground Content
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: effectiveTop,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Row Title + Badge Putaran
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                      height: 1.25,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (shouldDisplayBadge) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.pageHeaderBadge,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      cycleLabel!.trim(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Subtitle: Nama Siswa • Kelas
                            Text(
                              formattedSubtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.1,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (actionButton != null) ...[
                        const SizedBox(width: 8),
                        actionButton!,
                      ],
                    ],
                  ),
                  if (bottomChild != null) ...[
                    const SizedBox(height: 14),
                    bottomChild!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias typedef for uppercase notation compatibility
typedef SCPPageHeader = ScpPageHeader;

