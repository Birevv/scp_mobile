import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/buttons/primary_button.dart';

class SplashScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onFinish;
  final Duration minimumDuration;

  const SplashScreen({
    super.key,
    required this.state,
    this.onFinish,
    this.minimumDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  Timer? _timer;
  bool _minDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    widget.state.addListener(_onAuthStateChanged);

    if (widget.minimumDuration == Duration.zero) {
      _minDurationElapsed = true;
      _maybeFinish();
    } else {
      _timer = Timer(widget.minimumDuration, () {
        if (!mounted) return;
        _minDurationElapsed = true;
        _maybeFinish();
      });
    }
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    _maybeFinish();
  }

  void _maybeFinish() {
    if (!_minDurationElapsed) return;
    if (widget.state.authStatus == AuthStatus.checking) return;
    if (widget.state.authStatus == AuthStatus.connectionError) return;

    widget.onFinish?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.state.removeListener(_onAuthStateChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnectionError =
        widget.state.authStatus == AuthStatus.connectionError;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo & App Identity with Animation
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Official Logo SMK Negeri 1 Bantul
                      Image.asset(
                        'assets/images/SMK_Negeri_1_Bantul_logo.png',
                        width: 112,
                        height: 112,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),

                      // Nama Aplikasi
                      Text(
                        'School Class Progress App',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF0F172A),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Identitas SMK
                      Text(
                        'SMK Negeri 1 Bantul',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 44),

              // Loading Indicator / Connection Error Card
              if (isConnectionError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLarge),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.statusAlpa,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Gangguan Koneksi Server',
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.state.authErrorMessage ??
                              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
                          style: AppTypography.smallHint.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Coba Lagi',
                          icon: Icons.refresh_rounded,
                          onPressed: () {
                            widget.state.checkInitialAuth();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Horizontal Blue Loading Bar with rounded ends
                    SizedBox(
                      width: 168,
                      height: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                          backgroundColor: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Memuat aplikasi...',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
