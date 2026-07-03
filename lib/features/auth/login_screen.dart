import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../home/main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _keyController = TextEditingController();

  void _login() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainNavScreen(),
        transitionsBuilder: (_, anim, _, child) {          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
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

          // Content
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
                      // Title
                      Text(
                        'Log in or\nSign up',
                        style: AppTextStyles.h1.copyWith(
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // License key + QR row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  const Icon(Icons.confirmation_number_outlined,
                                      size: 20,
                                      color: AppColors.textTertiary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _keyController,
                                      style: AppTextStyles.body,
                                      decoration: InputDecoration(
                                        hintText: 'Enter License Key',
                                        hintStyle: AppTextStyles.body.copyWith(
                                            color: AppColors.textTertiary),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Login button
                      _PrimaryButton(
                        label: 'Login',
                        onTap: _login,
                        showArrow: true,
                        bgColor: Colors.white,
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 32),

                      // OR divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                                color: AppColors.borderSubtle, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                                color: AppColors.borderSubtle, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email button
                      _SocialButton(
                        icon: Icons.email_outlined,
                        label: 'Continue with Email',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),

                      // Google button
                      _SocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Continue with Google',
                        badge: '10GB Free',
                        onTap: () {},
                      ),
                      const Spacer(),

                      // Language selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.translate_rounded,
                                size: 16,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'ENGLISH',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more_rounded,
                                size: 16,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary),
                          children: [
                            const TextSpan(
                                text:
                                    'By continuing you agree to the\n'),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
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

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool showArrow;
  final Color bgColor;
  final Color textColor;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.showArrow = false,
    required this.bgColor,
    required this.textColor,
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
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.showArrow)
                Positioned(
                  right: 20,
                  child: Icon(Icons.arrow_forward_rounded,
                      color: widget.textColor, size: 20),
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
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, size: 24, color: AppColors.textSecondary),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}
