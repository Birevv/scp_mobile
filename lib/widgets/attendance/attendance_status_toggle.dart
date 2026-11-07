import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';

class AttendanceStatusToggle extends StatefulWidget {
  final String? initialStatus; // 'H', 'I', 'S', 'A'
  final ValueChanged<String> onStatusChanged;
  final bool isReadOnly;

  const AttendanceStatusToggle({
    super.key,
    this.initialStatus,
    required this.onStatusChanged,
    this.isReadOnly = false,
  });

  @override
  State<AttendanceStatusToggle> createState() => _AttendanceStatusToggleState();
}

class _AttendanceStatusToggleState extends State<AttendanceStatusToggle> {
  late String _selectedStatus;

  static const Map<String, Color> statusColors = {
    'H': AppColors.successHadir, // Emerald
    'I': AppColors.infoIzin,     // Sky Blue
    'S': AppColors.warningSakit, // Amber
    'A': AppColors.errorAlpa,    // Red
  };

  static const Map<String, String> statusLabels = {
    'H': 'Hadir',
    'I': 'Izin',
    'S': 'Sakit',
    'A': 'Alpa',
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus ?? 'H';
  }

  @override
  void didUpdateWidget(covariant AttendanceStatusToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != null && widget.initialStatus != _selectedStatus) {
      _selectedStatus = widget.initialStatus!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: statusColors.keys.map((status) {
        final isSelected = _selectedStatus.toUpperCase() == status;
        final color = statusColors[status]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Tooltip(
            message: statusLabels[status] ?? status,
            child: InkWell(
              onTap: widget.isReadOnly
                  ? null
                  : () {
                      setState(() => _selectedStatus = status);
                      widget.onStatusChanged(status);
                    },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected ? color : AppColors.white,
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1.2,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    status,
                    style: AppTypography.microBadge.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
