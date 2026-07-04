import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/vpn_provider.dart';
import 'core/network/api_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/main_nav_screen.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.init();

    if (auth.isLoggedIn && mounted) {
      // ثبت دستگاه و بارگذاری داده‌های اصلی
      await _registerDevice();
      if (mounted) {
        await context.read<VpnProvider>().init();
      }
    }
  }

  Future<void> _registerDevice() async {
    try {
      final plugin = DeviceInfoPlugin();
      String fingerprint = '';
      String platform = 'android';
      String? deviceName;

      if (Theme.of(context).platform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        fingerprint = info.id;
        deviceName = '${info.brand} ${info.model}';
        platform = 'android';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        fingerprint = info.identifierForVendor ?? info.name;
        deviceName = info.name;
        platform = 'ios';
      } else {
        // Windows/other برای تست
        fingerprint = 'dev-${DateTime.now().millisecondsSinceEpoch}';
        deviceName = 'Desktop';
        platform = 'android';
      }

      final deviceId = await ApiService.registerDevice(
        fingerprint: fingerprint,
        platform: platform,
        deviceName: deviceName,
      );
      if (mounted) {
        context.read<VpnProvider>().setDeviceId(deviceId);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.unknown:
            return const _SplashScreen();
          case AuthStatus.unauthenticated:
            return const OnboardingScreen();
          case AuthStatus.authenticated:
            return const MainNavScreen();
        }
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A7DFF),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
