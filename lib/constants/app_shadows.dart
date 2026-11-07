import 'package:flutter/material.dart';

class AppShadows {
  // Soft shadow for cards (PRD 7.1: 0 2px 8px rgba(0,0,0,0.06))
  static const BoxShadow softShadow = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.05),
    blurRadius: 12.0,
    offset: Offset(0, 4),
  );

  // Medium shadow for elevated elements / floating cards
  static const BoxShadow mediumShadow = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.08),
    blurRadius: 16.0,
    offset: Offset(0, 6),
  );

  // Large shadow for modals/bottom sheets
  static const BoxShadow largeShadow = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.14),
    blurRadius: 24.0,
    offset: Offset(0, 8),
  );

  static const List<BoxShadow> cardShadows = [softShadow];
  static const List<BoxShadow> elevatedShadows = [mediumShadow];
  static const List<BoxShadow> modalShadows = [largeShadow];
}
