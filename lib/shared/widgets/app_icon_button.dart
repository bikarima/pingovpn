import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final double size;
  final Color? backgroundColor;
  final bool hasNotification;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.backgroundColor,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Center(child: icon),
          ),
          if (hasNotification)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.statusError,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
