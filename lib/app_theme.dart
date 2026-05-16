import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:series_watcher_fschmatz/pages/home.dart';

class AppTheme extends StatefulWidget {
  const AppTheme({super.key});

  @override
  State<AppTheme> createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final darkScheme = darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme.copyWith(surface: darkScheme.surfaceContainer), useMaterial3: true),
          themeMode: EasyDynamicTheme.of(context).themeMode,
          home: const Home(),
        );
      },
    );
  }
}
