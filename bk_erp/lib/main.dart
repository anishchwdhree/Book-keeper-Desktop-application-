import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BkErpApp());
}

class BkErpApp extends StatelessWidget {
  const BkErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramgarm Seed Company (PVT) Ltd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
      // Ensure media query always reports at least the minimum enforced by Win32.
      // This prevents widgets from trying to render at 0-size during init.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final constrainedSize = Size(
          mediaQuery.size.width.clamp(1100.0, double.infinity),
          mediaQuery.size.height.clamp(700.0, double.infinity),
        );
        return MediaQuery(
          data: mediaQuery.copyWith(size: constrainedSize),
          child: child!,
        );
      },
    );
  }
}
