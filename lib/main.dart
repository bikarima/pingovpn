import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/vpn_provider.dart';
import 'app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // جلوگیری از دانلود فونت در runtime — از cache یا system استفاده می‌کنه
  GoogleFonts.config.allowRuntimeFetching = false;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const PingoApp());
}

class PingoApp extends StatelessWidget {
  const PingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VpnProvider()),
      ],
      child: MaterialApp(
        title: 'Pingo VPN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppRouter(),
      ),
    );
  }
}
