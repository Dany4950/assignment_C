import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown instead of the app when Firebase cannot start (usually: config files missing).
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Firebase is not configured',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const Text(
                  'Run `flutterfire configure` (or add google-services.json and '
                  'GoogleService-Info.plist), then restart the app. See README > Firebase setup.',
                ),
                const SizedBox(height: 16),
                Text('$error', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
