import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.shield_rounded,
      iconColor: const Color(0xFF4A7DFF),
      title: 'Browse Privately',
      subtitle: 'Your online activity stays hidden.\nProtect yourself from trackers & spies.',
    ),
    _OnboardingData(
      icon: Icons.bolt_rounded,
      iconColor: const Color(0xFFF59E0B),
      title: 'Blazing Fast Speed',
      subtitle: 'Ultra-low latency servers optimized\nfor gaming, streaming & browsing.',
    ),
    _OnboardingData(
      icon: Icons.public_rounded,
      iconColor: const Color(0xFF22C55E),
      title: '500+ Servers Worldwide',
      subtitle: 'Connect to any region instantly.\nAlways find the fastest server near you.',
    ),
    _OnboardingData(
      icon: Icons.lock_rounded,
      iconColor: const Color(0xFFA855F7),
      title: 'Your Data, Your Rules',
      subtitle: 'Military-grade encryption keeps\nyour data safe and private.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 8,
              right: 20,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  'Skip',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),

            // Page content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _OnboardingPage(data: _pages[index], screenSize: size);
              },
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    // Dot indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accentPrimary
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // Action button
                    _ActionButton(
                      label: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onTap: _nextPage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Size screenSize;

  const _OnboardingPage({required this.data, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.1),
          // Illustration
          Container(
            width: screenSize.width,
            height: screenSize.height * 0.38,
            constraints: const BoxConstraints(maxHeight: 320),
            child: _OnboardingIllustration(
              icon: data.icon,
              iconColor: data.iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            data.title,
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _OnboardingIllustration({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        // Middle ring
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        // Inner circle with icon
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.1),
            border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, size: 64, color: iconColor),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
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
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
