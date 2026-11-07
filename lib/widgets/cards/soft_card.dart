import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_shadows.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Color? color;
  final Border? border;
  final double? borderRadius;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.height,
    this.width,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLarge),
        child: Ink(
          height: height,
          width: width,
          padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: color ?? AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLarge),
            border: border ??
                Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
            boxShadow: AppShadows.cardShadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
