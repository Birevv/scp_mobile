import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/alert_card.dart';

class LoginScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.state,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRememberedUsername();
  }

  Future<void> _loadRememberedUsername() async {
    final savedUsername = await widget.state.tokenStorage.readSavedUsername();
    if (!mounted) return;
    if (savedUsername != null && savedUsername.isNotEmpty) {
      _usernameController.text = savedUsername;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await widget.state.login(
      identifier: _usernameController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res.success && widget.state.isAuthenticated) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        if (res.isNetworkError) {
          _errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        } else if (res.statusCode == 401 || res.statusCode == 422) {
          _errorMessage = 'Username atau kata sandi tidak sesuai.';
        } else {
          _errorMessage = res.message;
        }
      });
    }
  }

  void _showForgotPasswordOtpSheet() {
    final emailCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool otpSent = false;
    bool busy = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
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
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.lightIndigoBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.primaryIndigo,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otpSent
                                      ? 'Verifikasi OTP & Password Baru'
                                      : 'Reset Password via OTP Email',
                                  style: AppTypography.sectionTitle,
                                ),
                                Text(
                                  otpSent
                                      ? 'Masukkan 6 digit kode OTP yang dikirim ke email'
                                      : 'Masukkan email akun terdaftar untuk menerima kode OTP',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Email Terdaftar', style: AppTypography.cardTitle),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailCtrl,
                        enabled: !otpSent,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan alamat email akun sekolah',
                          prefixIcon: Icon(Icons.email_outlined, size: 19),
                        ),
                      ),
                      if (otpSent) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Kode OTP (6 Digit)',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: otpCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan 6 digit OTP',
                            counterText: '',
                            prefixIcon: Icon(Icons.pin_outlined, size: 19),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Password Baru (Min. 8 Karakter)',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Minimal 8 karakter',
                            prefixIcon: Icon(Icons.lock_outline, size: 19),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Konfirmasi Password Baru',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Ulangi password baru',
                            prefixIcon:
                                Icon(Icons.verified_user_outlined, size: 19),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: otpSent
                            ? 'Reset Password Sekarang'
                            : 'Kirim Kode OTP',
                        icon: otpSent
                            ? Icons.check_circle_outline
                            : Icons.send_rounded,
                        isLoading: busy,
                        onPressed: () async {
                          if (!otpSent) {
                            if (emailCtrl.text.trim().isEmpty) return;
                            setSheetState(() => busy = true);
                            final res = await widget.state
                                .sendPasswordOtp(emailCtrl.text.trim());
                            if (!ctx.mounted || !mounted) return;
                            setSheetState(() {
                              busy = false;
                              if (res.success) otpSent = true;
                            });
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(res.message),
                                backgroundColor: res.success
                                    ? AppColors.secondaryTeal
                                    : AppColors.statusAlpa,
                              ),
                            );
                          } else {
                            if (otpCtrl.text.trim().length != 6 ||
                                passCtrl.text.length < 8 ||
                                passCtrl.text != confirmCtrl.text) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pastikan OTP 6 digit & Password minimal 8 karakter sama!',
                                  ),
                                  backgroundColor: AppColors.statusAlpa,
                                ),
                              );
                              return;
                            }
                            setSheetState(() => busy = true);
                            final res = await widget.state.resetPasswordOtp(
                              email: emailCtrl.text.trim(),
                              otp: otpCtrl.text.trim(),
                              password: passCtrl.text,
                              passwordConfirmation: confirmCtrl.text,
                            );
                            if (!ctx.mounted || !mounted) return;
                            setSheetState(() => busy = false);
                            if (res.success) {
                              Navigator.pop(ctx);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res.message),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Identitas (Notion-style: Minimal, Ringkas, Elegan)
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/SMK_Negeri_1_Bantul_logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'School Class Progress App',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF172033),
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'SMK Negeri 1 Bantul',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Judul & Deskripsi Autentikasi (Main Headline)
                  Text(
                    'Autentikasi Pengguna',
                    style: AppTypography.heading1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172033),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk menggunakan NISN, NIP, atau username akun resmi sekolah Anda.',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 13.5,
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    AlertCard(
                      type: AlertType.error,
                      message: _errorMessage!,
                      onClose: () => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 2. Form Autentikasi Card (Notion-style: Bersih, Presisi, Whitespace Terukur)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDCE4EF),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label NISN / NIP / Username
                          Text(
                            'NISN / NIP / Username',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('login_identifier_field'),
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            style: AppTypography.bodyText.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF172033),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan NISN, NIP, atau Username',
                              hintStyle: AppTypography.smallHint.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 13.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDCE4EF),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF203D8D),
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.statusAlpa,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.statusAlpa,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'NISN / NIP / Username wajib diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Label Kata Sandi
                          Text(
                            'Kata Sandi',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            style: AppTypography.bodyText.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF172033),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan kata sandi akun',
                              hintStyle: AppTypography.smallHint.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 13.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDCE4EF),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF203D8D),
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.statusAlpa,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.statusAlpa,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Kata sandi wajib diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Opsi Tambahan: Ingat Saya & Lupa Kata Sandi?
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 6,
                              children: [
                                InkWell(
                                  onTap: () => setState(
                                    () => _rememberMe = !_rememberMe,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: const Color(0xFF203D8D),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFDCE4EF),
                                              width: 1.5,
                                            ),
                                            onChanged: (val) => setState(
                                              () => _rememberMe = val ?? true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ingat Saya',
                                          style: AppTypography.smallHint.copyWith(
                                            fontSize: 12.5,
                                            color: const Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: _showForgotPasswordOtpSheet,
                                  child: Text(
                                    'Lupa Kata Sandi?',
                                    style: AppTypography.smallHint.copyWith(
                                      color: const Color(0xFF203D8D),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Tombol Masuk ke Sistem (Primary Action)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF203D8D),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBackgroundColor: const Color(0xFF203D8D)
                                    .withValues(alpha: 0.6),
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.login_rounded,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Masuk ke Sistem',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                AppTypography.labelButton.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Informasi Bantuan Teknis
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFDCE4EF),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDCE4EF),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.headset_mic_outlined,
                            color: Color(0xFF203D8D),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Bantuan Teknis',
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF203D8D),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Apabila mengalami kendala akses akun atau perubahan data NISN/NIP, silakan hubungi Administrator Sistem SCP.',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11.5,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
