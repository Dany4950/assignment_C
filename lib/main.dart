import 'package:capassignment/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/app_dependencies.dart';
import 'core/widgets/bootstrap_error_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
  try {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,

    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    final prefs = await SharedPreferences.getInstance();
    runApp(RumourApp(createDependencies: () => AppDependencies.live(prefs)));
  } catch (error, stack) {
    debugPrint('Bootstrap failed: $error\n$stack');
    runApp(BootstrapErrorApp(error: error));
  }
}
