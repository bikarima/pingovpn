import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/state/connection_state.dart';

class PowerButton extends StatefulWidget {
  final VpnConnectionStatus status;
  final VoidCallback onTap;

  const PowerButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with TickerProviderStateMixin {
  late List<AnimationController> _radarControllers;
  late List<Animation<double>> _radarScales;
  late List<Animation<double>> _radarOpacities;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initRadar();
    _initPulse();
  }

  void _initRadar() {
    _radarControllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      );
    });

    _radarScales = _radarControllers.map((ctrl) {
      return Tween<double>(begin: 1.0, end: 2.2).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
      );
    }).toList();

    _radarOpacities = _radarControllers.map((ctrl) {
      return Tween<double>(begin: 0.6, end: 0.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
      );
    }).toList();

    _startRadarIfNeeded();
  }

  void _initPulse() {
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  void _startRadarIfNeeded() {
    if (widget.status == VpnConnectionStatus.connected) {
      for (var i = 0; i < _radarControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 600), () {
          if (mounted) {
            _radarControllers[i].repeat();
          }
        });
      }
    }
  }

  void _stopRadar() {
    for (var ctrl in _radarControllers) {
      ctrl.reset();
      ctrl.stop();
    }
  }

  @override
  void didUpdateWidget(PowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (widget.status == VpnConnectionStatus.connected) {
        _startRadarIfNeeded();
        _pulseCtrl.stop();
      } else if (widget.status == VpnConnectionStatus.connecting) {
        _stopRadar();
        _pulseCtrl.repeat(reverse: true);
      } else {
        _stopRadar();
        _pulseCtrl.stop();
        _pulseCtrl.reset();
      }
    }
  }

  @override
  void dispose() {
    for (var ctrl in _radarControllers) {
      ctrl.dispose();
    }
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _buttonColor {
    switch (widget.status) {
      case VpnConnectionStatus.disconnected:
      case VpnConnectionStatus.error:
        return const Color(0xFF4B5563);
      case VpnConnectionStatus.connecting:
        return AppColors.statusConnecting;
      case VpnConnectionStatus.connected:
        return AppColors.statusConnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.status == VpnConnectionStatus.connecting ? null : widget.onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radar rings (only when connected)
            if (widget.status == VpnConnectionStatus.connected)
              ...List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _radarControllers[i],
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _radarScales[i].value,
                      child: Opacity(
                        opacity: _radarOpacities[i].value,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.statusConnected,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

            // Main button
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                final opacity = widget.status == VpnConnectionStatus.connecting
                    ? _pulseAnim.value
                    : 1.0;
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.status == VpnConnectionStatus.connected
                      ? null
                      : _buttonColor,
                  gradient: widget.status == VpnConnectionStatus.connected
                      ? AppColors.gradientConnected
                      : null,
                  boxShadow: widget.status == VpnConnectionStatus.connected
                      ? AppColors.glowConnected
                      : widget.status == VpnConnectionStatus.connecting
                          ? AppColors.glowConnecting
                          : null,
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
