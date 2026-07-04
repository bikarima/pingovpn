import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/vpn_provider.dart';
import '../../core/network/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _keyController     = TextEditingController();
  final _emailController   = TextEditingController();
  final _passController    = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _showEmailForm = false;

  @override
  void dispose() {
    _keyController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // ── License redeem (guest + redeem) ───────────────────────
  Future<void> _redeemLicense() async {
    final code = _keyController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a license key');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final auth = context.read<AuthProvider>();

    // 1. Guest login
    final guestOk = await auth.loginAsGuest();
    if (!mounted) return;
    if (!guestOk) {
      setState(() { _isLoading = false; _error = auth.error ?? 'Login failed'; });
      return;
    }

    // 2. Redeem license
    final result = await auth.redeemLicense(code);
    if (!mounted) return;
    if (result == null) {
      // کد اشتباهه — logout و نشون دادن error
      await auth.logout();
      setState(() { _isLoading = false; _error = auth.error ?? 'Invalid code'; });
      return;
    }

    await _postLogin();
  }

  // ── Email login ───────────────────────────────────────────
  Future<void> _emailLogin() async {
    final email = _emailController.text.trim();
    final pass  = _passController.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Fill in email and password');
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(email, pass);
    if (!mounted) return;
    if (!ok) {
      setState(() { _isLoading = false; _error = auth.error ?? 'Login failed'; });
      return;
    }
    await _postLogin();
  }

  // ── After login: register device + load VPN data ──────────
  Future<void> _postLogin() async {
    try {
      final plugin = DeviceInfoPlugin();
      String fp = 'dev-${DateTime.now().millisecondsSinceEpoch}';
      String platform = 'android';
      String? deviceName;

      if (!mounted) return;
      final targetPlatform = Theme.of(context).platform;
      if (targetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        fp = info.id;
        deviceName = '${info.brand} ${info.model}';
      } else if (targetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        fp = info.identifierForVendor ?? fp;
        deviceName = info.name;
        platform = 'ios';
      }

      final deviceId = await ApiService.registerDevice(
        fingerprint: fp,
        platform: platform,
        deviceName: deviceName,
      );
      if (mounted) context.read<VpnProvider>().setDeviceId(deviceId);
    } catch (_) {}

    if (mounted) {
      await context.read<VpnProvider>().init();
      if (mounted) setState(() => _isLoading = false);
      // AppRouter هوشمندانه navigate می‌کنه از طریق AuthProvider state
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background radial gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.85),
                radius: 1.0,
                colors: [Color(0xFF1E3A8A), Color(0xFF000000)],
                stops: [0.0, 0.6],
              ),
            ),
          ),
          // Decorative rings
          ..._buildRings(size),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Text(
                        'Log in or\nSign up',
                        style: AppTextStyles.h1.copyWith(height: 1.15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // ── License key row ──────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _InputBox(
                              controller: _keyController,
                              hint: 'Enter License Key',
                              icon: Icons.confirmation_number_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _QrButton(onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Error message ────────────────────
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.statusError.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            _error!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.statusError,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (_error != null) const SizedBox(height: 12),

                      // ── Login button ─────────────────────
                      _PrimaryButton(
                        label: 'Login with License',
                        isLoading: _isLoading,
                        onTap: _isLoading ? null : _redeemLicense,
                        showArrow: true,
                      ),
                      const SizedBox(height: 32),

                      // ── OR divider ───────────────────────
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: AppColors.borderSubtle,
                                  thickness: 1)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textTertiary)),
                          ),
                          Expanded(
                              child: Divider(
                                  color: AppColors.borderSubtle,
                                  thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Email form (toggle) ──────────────
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _showEmailForm
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _SocialButton(
                          icon: Icons.email_outlined,
                          label: 'Continue with Email',
                          onTap: () =>
                              setState(() => _showEmailForm = true),
                        ),
                        secondChild: Column(
                          children: [
                            _InputBox(
                              controller: _emailController,
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            _InputBox(
                              controller: _passController,
                              hint: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscure: true,
                            ),
                            const SizedBox(height: 12),
                            _PrimaryButton(
                              label: 'Login',
                              isLoading: _isLoading,
                              onTap: _isLoading ? null : _emailLogin,
                              showArrow: true,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _showEmailForm = false),
                              child: Text('Back',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Google button ────────────────────
                      if (!_showEmailForm)
                        _SocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Continue with Google',
                          badge: '10GB Free',
                          onTap: () {},
                        ),

                      const Spacer(),

                      // ── Language selector ────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          border:
                              Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.translate_rounded,
                                size: 16,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('ENGLISH',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textPrimary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more_rounded,
                                size: 16,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Terms ────────────────────────────
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary),
                          children: [
                            const TextSpan(
                                text: 'By continuing you agree to the\n'),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline),
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
        ],
      ),
    );
  }

  List<Widget> _buildRings(Size size) {
    final center = Offset(size.width / 2, size.height * 0.15);
    return [150.0, 250.0, 350.0].map((radius) {
      return Positioned(
        left: center.dx - radius,
        top: center.dy - radius,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ─── Reusable widgets ─────────────────────────────────────────

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _InputBox({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.body
                    .copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _QrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Icon(Icons.qr_code_scanner_rounded,
            color: AppColors.textSecondary),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.showArrow = false,
    this.isLoading = false,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null && !widget.isLoading;
    return GestureDetector(
      onTapDown: active ? (_) => _ctrl.forward() : null,
      onTapUp: active
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.black54),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.showArrow)
                      const Positioned(
                        right: 20,
                        child: Icon(Icons.arrow_forward_rounded,
                            color: Colors.black, size: 20),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, size: 24, color: AppColors.textSecondary),
            Expanded(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textPrimary)),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(badge!,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}
