import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_icon_button.dart';

enum _TestState { idle, testing, done }

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with TickerProviderStateMixin {
  _TestState _state = _TestState.idle;

  double _currentSpeed = 0;
  double _ping = 0;
  double _download = 0;
  double _upload = 0;

  late AnimationController _needleCtrl;
  late Animation<double> _needleAnim;
  Timer? _testTimer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _needleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _needleAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _needleCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _needleCtrl.dispose();
    _testTimer?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _state = _TestState.testing;
      _currentSpeed = 0;
      _ping = 0;
      _download = 0;
      _upload = 0;
      _tick = 0;
    });

    final rng = math.Random();
    _testTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _tick++;
      double speed;
      if (_tick < 10) {
        // Ping phase
        speed = (_tick * 2.5).clamp(0, 20);
        setState(() {
          _ping = 12 + rng.nextDouble() * 8;
          _currentSpeed = speed;
        });
      } else if (_tick < 30) {
        // Download phase
        speed = ((_tick - 10) * 4.5).clamp(0, 95);
        setState(() {
          _download = speed;
          _currentSpeed = speed;
        });
      } else if (_tick < 45) {
        // Upload phase
        speed = ((_tick - 30) * 3.2).clamp(0, 50);
        setState(() {
          _upload = speed;
          _currentSpeed = speed;
        });
      } else {
        timer.cancel();
        setState(() {
          _state = _TestState.done;
          _currentSpeed = _download;
        });
      }

      // Animate needle
      final targetAngle = (_currentSpeed / 100).clamp(0.0, 1.0);
      _needleAnim = Tween<double>(
        begin: _needleAnim.value,
        end: targetAngle,
      ).animate(CurvedAnimation(parent: _needleCtrl, curve: Curves.elasticOut));
      _needleCtrl.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGauge(),
                  const SizedBox(height: 16),
                  _buildSpeedNumber(),
                  const SizedBox(height: 40),
                  _buildStatCards(),
                  const Spacer(),
                  _buildActionButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                size: 20, color: AppColors.textPrimary),
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'SPEED TEST',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildGauge() {
    return AnimatedBuilder(
      animation: _needleAnim,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(260, 140),
          painter: _GaugePainter(
            value: _needleAnim.value,
            isAnimating: _state == _TestState.testing,
          ),
        );
      },
    );
  }

  Widget _buildSpeedNumber() {
    return Column(
      children: [
        Text(
          _state == _TestState.idle
              ? '0.0'
              : _currentSpeed.toStringAsFixed(1),
          style: AppTextStyles.percentLarge.copyWith(fontSize: 48),
        ),
        Text(
          'Mbps',
          style: AppTextStyles.caption.copyWith(fontSize: 14, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.network_ping_rounded,
            label: 'Ping',
            value: _ping > 0 ? '${_ping.toStringAsFixed(0)}ms' : '--',
            color: AppColors.statusConnected,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.arrow_downward_rounded,
            label: 'Download',
            value: _download > 0
                ? '${_download.toStringAsFixed(1)} Mbps'
                : '--',
            color: AppColors.accentPrimary,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.arrow_upward_rounded,
            label: 'Upload',
            value: _upload > 0
                ? '${_upload.toStringAsFixed(1)} Mbps'
                : '--',
            color: const Color(0xFFA855F7),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: GestureDetector(
        onTap: _state == _TestState.testing ? null : _startTest,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _state == _TestState.testing
                ? AppColors.surfaceCard
                : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          alignment: Alignment.center,
          child: _state == _TestState.testing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Testing...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Text(
                  _state == _TestState.done ? 'Test Again' : 'Start Test',
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final bool isAnimating;

  _GaugePainter({required this.value, required this.isAnimating});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.surfaceCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: [
          Color(0xFF22C55E),
          Color(0xFFF59E0B),
          Color(0xFFEF4444),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * value,
      false,
      gradientPaint,
    );

    // Needle
    final needleAngle = math.pi + (math.pi * value);
    final needleLength = radius - 4;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, 8, Paint()..color = AppColors.surfaceCardHover);
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);

    // Speed labels
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    final labels = ['0', '25', '50', '75', '100'];
    for (var i = 0; i < labels.length; i++) {
      final angle = math.pi + (math.pi * i / (labels.length - 1));
      final labelRadius = radius + 20;
      final pos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );
      labelPaint.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 10,
        ),
      );
      labelPaint.layout();
      labelPaint.paint(
        canvas,
        pos - Offset(labelPaint.width / 2, labelPaint.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.isAnimating != isAnimating;
}
