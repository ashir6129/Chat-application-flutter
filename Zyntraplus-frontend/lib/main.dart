import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyntraplus/core/connectivity_service.dart';
import 'package:zyntraplus/core/app_navigator.dart';
import 'package:zyntraplus/core/image_cache_service.dart';
import 'package:zyntraplus/core/offline_cache_service.dart';
import 'package:zyntraplus/core/offline_message_queue.dart';
import 'package:zyntraplus/login_screen/auth_screen.dart';
import 'package:zyntraplus/login_screen/splash_screen.dart';
import 'package:zyntraplus/screens/call/incoming_call_overlay.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OfflineCacheService.init();
  await ImageCacheService.init();
  await ConnectivityService.init();
  await OfflineMessageQueue.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme');
  themeModeNotifier.value =
  savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        navigatorKey: rootNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Zyntra Plus',
        theme: ThemeData(
          fontFamily: 'MyCustomFont',
          fontFamilyFallback: const ['Noto Color Emoji', 'Segoe UI Emoji', 'Apple Color Emoji'],
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          fontFamily: 'MyCustomFont',
          fontFamilyFallback: const ['Noto Color Emoji', 'Segoe UI Emoji', 'Apple Color Emoji'],
          brightness: Brightness.dark,
        ),
        themeMode: mode,
        builder: (context, child) {
          return IncomingCallOverlay(
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}