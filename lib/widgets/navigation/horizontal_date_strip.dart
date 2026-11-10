import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

/// HorizontalDateStrip - Pemilih Hari Interaktif Modern
/// Memenuhi lebar layar secara proporsional (Senin s/d Jumat terdistribusi rata ke kanan)
class HorizontalDateStrip extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onDaySelected;
  final List<String> days;
  final String? todayDayName;

  const HorizontalDateStrip({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.days = const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'],
    this.todayDayName,
  });

  String _getShortDay(String fullDay) {
    switch (fullDay.toLowerCase()) {
      case 'senin':
        return 'SEN';
      case 'selasa':
        return 'SEL';
      case 'rabu':
        return 'RAB';
      case 'kamis':
        return 'KAM';
      case 'jumat':
        return 'JUM';
      case 'sabtu':
        return 'SAB';
      case 'minggu':
        return 'MIN';
      default:
        return fullDay.length >= 3 ? fullDay.substring(0, 3).toUpperCase() : fullDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSelected = selectedDay.toLowerCase() == day.toLowerCase();
        final isToday = todayDayName != null &&
            todayDayName!.toLowerCase() == day.toLowerCase();
        final shortDay = _getShortDay(day);
        final isLast = index == days.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onDaySelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandPrimary
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.brandPrimary.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Singkatan hari (SEN, SEL, dst)
                      Text(
                        shortDay,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Nama hari lengkap
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          day,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // Penanda titik jika "Hari Ini"
                      if (isToday) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white
                                : AppColors.brandPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
